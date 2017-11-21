//
//  SGARSingleFingerGestureHandler.m
//  SogouAR
//
//  Created by fk on 2017/11/17.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "SGARSingleFingerGestureHandler.h"

static const CGFloat kTranslationThreshold = 30;

@interface SGARSingleFingerGestureHandler ()


@property (nonatomic, assign) CGPoint initialTouchLocation;
@property (nonatomic, assign) CGPoint latestTouchLocation;
@property (nonatomic, assign) CGPoint dragOffset;

@property (nonatomic, strong) SGARObject *firstTouchedObject;

@property (nonatomic, assign) BOOL translationThresholdPassed;
@property (nonatomic, assign) BOOL hasMovedObject;


@end


@implementation SGARSingleFingerGestureHandler


- (instancetype)initWithTouches:(NSSet<UITouch *> *)touches
                      sceneView:(ARSCNView *)secneView
                 lastUsedObject:(SGARObject *)lastUsedObject
                  objectManager:(SGARObjectManager *)objectManager {
    
    self = [super initWithTouches:touches sceneView:secneView lastUsedObject:lastUsedObject objectManager:objectManager];
    if (self) {
        
        _hasMovedObject = NO;
        _translationThresholdPassed = NO;
        
        __block UITouch *touch = nil;
        [self.currentTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
            touch = obj;
            *stop = YES;
        }];

        if (touch) {
            _initialTouchLocation = [touch locationInView:secneView];
            _latestTouchLocation = _initialTouchLocation;
            _firstTouchedObject = [self virtualObjectAtPoint:_initialTouchLocation];
        }
    }
    return self;
}

- (void)updateGesture {
    
    [super updateGesture];
    
    if (!_firstTouchedObject) {
        return;
    }
    
    SGARObject *virtualObject = _firstTouchedObject;
    [self.currentTouches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
        _latestTouchLocation = [obj locationInView:self.sceneView];
    }];
    
    if (!_translationThresholdPassed) {
        
        
        CGFloat distanceFromStartLocation = [SGARGestureHandler distanceFrom:_latestTouchLocation toPoint:_initialTouchLocation];
        
        if (distanceFromStartLocation >= kTranslationThreshold) {
            _translationThresholdPassed = YES;
            
            SCNVector3 currentObjectLocation = [self.sceneView projectPoint:virtualObject.position];
            
            _dragOffset = CGPointMake(_latestTouchLocation.x - currentObjectLocation.x,
                                       _latestTouchLocation.y - currentObjectLocation.y);
        }
    }
        
    if (_translationThresholdPassed) {
        CGPoint offsetPos = CGPointMake(_latestTouchLocation.x - _dragOffset.x,
                                        _latestTouchLocation.y - _dragOffset.y);
        [self.objectManager translate:virtualObject
                          inSceneView:self.sceneView
                               baseOn:offsetPos
                            instantly:NO
                        infinitePlane:YES];
        _hasMovedObject = YES;
        self.lastUsedObject = virtualObject;
    }
}

- (void)finishGesture {
    
    if (self.currentTouches.count > 1) {
        return;
    }
    
    if (_hasMovedObject) {
        return;
    }
    
    if (self.lastUsedObject != nil) {
        
        BOOL isObjectHit = NO;

        if ([self virtualObjectAtPoint:_initialTouchLocation] != nil) {
            isObjectHit = YES;
        }
        
        if (!isObjectHit) {
            if (!_translationThresholdPassed) {
                [self.objectManager translate:self.lastUsedObject inSceneView:self.sceneView baseOn:self.latestTouchLocation instantly:YES infinitePlane:NO];
            }
        }
    }
}

@end
