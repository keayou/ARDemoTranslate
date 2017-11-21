//
//  SGARGestureHandler.m
//  SogouAR
//
//  Created by fk on 2017/11/17.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "SGARGestureHandler.h"
#import "SGARSingleFingerGestureHandler.h"
#import "SGARTwoFingerGestureHandler.h"

@implementation SGARGestureHandler

+ (SGARGestureHandler *)fetchGestureFromTouches:(NSSet <UITouch *>*)touches
                                      sceneView:(ARSCNView *)secneView
                                 lastUsedObject:(SGARObject *)lastUsedObject
                                  objectManager:(SGARObjectManager *)objectManager {
    if (touches.count == 1) {
        return [[SGARSingleFingerGestureHandler alloc]initWithTouches:touches
                                                            sceneView:secneView
                                                       lastUsedObject:lastUsedObject
                                                        objectManager:objectManager];
    } else if (touches.count == 2) {
        return [[SGARTwoFingerGestureHandler alloc]initWithTouches:touches
                                                         sceneView:secneView
                                                    lastUsedObject:lastUsedObject
                                                     objectManager:objectManager];
    } else {
        return nil;
    }
}

- (instancetype)initWithTouches:(NSSet <UITouch *>*)touches
                      sceneView:(ARSCNView *)secneView
                 lastUsedObject:(SGARObject *)lastUsedObject
                  objectManager:(SGARObjectManager *)objectManager {
    
    self = [super init];
    if (self) {
        
        self.currentTouches = [NSMutableSet setWithSet:touches];
        self.sceneView = secneView;
        self.lastUsedObject = lastUsedObject;
        self.objectManager = objectManager;
        
        __weak typeof (self) weaksSelf = self;
        self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.016667
                                                            repeats:YES
                                                              block:^(NSTimer * _Nonnull timer) {
                                                                  [weaksSelf updateGesture];
                                                              }];
        
    }
    return self;
}

/// Hit tests against the `sceneView` to find an object at the provided point.
- (SGARObject *)virtualObjectAtPoint:(CGPoint)point {
    
    NSDictionary *dict = @{SCNHitTestBoundingBoxOnlyKey:@(YES)};
    
    NSArray<SCNHitTestResult *> *results= [self.sceneView hitTest:point options:dict];
    for (SCNHitTestResult *res in results) {
        
        SGARObject *arObject = [SGARObject isNodePartOfARObject:res.node];
        if (arObject) {
            return arObject;
            break;
        }
    }
    return nil;
}


- (void)updateGesture {
    
}

- (void)finishGesture {
    
}

- (SGARGestureHandler *)updateGestureFromTouches:(NSSet <UITouch *>*)touches touchType:(TouchEventType)type {
    
    if (touches.count == 0) {
        return self;
    }
    
    if (type == TouchEventBegan || type == TouchEventeMoved) {
        [self.currentTouches unionSet:touches];
    } else if (type == TouchEventEnded || type == TouchEventCancelled) {
        [touches enumerateObjectsUsingBlock:^(UITouch * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([self.currentTouches containsObject:obj]) {
                [self.currentTouches removeObject:obj];
            }
        }];
    }
    
    SGARGestureHandler *gesture = self;
    
    if ([gesture isKindOfClass:[SGARSingleFingerGestureHandler class]]) {
        if (self.currentTouches.count == 1) {
            [gesture updateGesture];
            return gesture;
        } else {
            [gesture finishGesture];
            [gesture.refreshTimer invalidate];
            gesture.refreshTimer = nil;
            return [SGARGestureHandler fetchGestureFromTouches:self.currentTouches sceneView:self.sceneView lastUsedObject:self.lastUsedObject objectManager:self.objectManager];
        }
        
    } else if ([gesture isKindOfClass:[SGARTwoFingerGestureHandler class]]) {
        
        if (self.currentTouches.count == 2) {
            [gesture updateGesture];
            return gesture;
            
        } else {
            [gesture finishGesture];
            [gesture.refreshTimer invalidate];
            gesture.refreshTimer = nil;
            return nil;
        }
    } else {
        return self;
    }
    
    
}

- (void)dealloc {
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}


+ (CGFloat)distanceFrom:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    
    CGPoint locationToLocation = CGPointMake(fromPoint.x - toPoint.x,
                                             fromPoint.y - toPoint.y);
    
    return sqrt(locationToLocation.x * locationToLocation.x + locationToLocation.y * locationToLocation.y);
}

+ (CGPoint)getMidPoint:(CGPoint)firstPoint second:(CGPoint)secondPoint {
    return CGPointMake((firstPoint.x + secondPoint.x) / 2, (firstPoint.y + secondPoint.y) / 2);
}

@end
