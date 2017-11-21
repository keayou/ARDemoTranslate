//
//  SGARTwoFingerGestureHandler.m
//  SogouAR
//
//  Created by fk on 2017/11/17.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "SGARTwoFingerGestureHandler.h"


static const CGFloat translationThreshold = 40;
static const CGFloat translationThresholdHarder = 70;

static const CGFloat rotationThreshold = M_PI / 15; // (12°)
static const CGFloat rotationThresholdHarder = M_PI / 10; // (18°)

static const CGFloat scaleThreshold = 50;
static const CGFloat scaleThresholdHarder = 90;

@interface SGARTwoFingerGestureHandler () {

    CGFloat objectBaseScale;
    BOOL allowTranslation;
    BOOL allowRotation;
    
    CGFloat initialDistanceBetweenFingers;
    CGFloat initialFingerAngle;
    CGFloat initialObjectAngle;
    
    CGPoint dragOffset;

}

@property (nonatomic, strong) UITouch *firstTouch;
@property (nonatomic, strong) UITouch *secondTouch;

@property (nonatomic, assign) CGPoint initialMidPoint;

@property (nonatomic, strong) SGARObject *firstTouchedObject;

@property (nonatomic, assign) BOOL translationThresholdPassed;
@property (nonatomic, assign) BOOL rotationThresholdPassed;
@property (nonatomic, assign) BOOL scaleThresholdPassed;


@end

@implementation SGARTwoFingerGestureHandler

- (instancetype)initWithTouches:(NSSet<UITouch *> *)touches
                      sceneView:(ARSCNView *)secneView
                 lastUsedObject:(SGARObject *)lastUsedObject
                  objectManager:(SGARObjectManager *)objectManager {
    
    self = [super initWithTouches:touches sceneView:secneView lastUsedObject:lastUsedObject objectManager:objectManager];
    if (self) {
        
        objectBaseScale = 1.0;
        allowTranslation = NO;
        allowRotation = NO;
        initialDistanceBetweenFingers = 0;
        initialFingerAngle = 0;
        initialObjectAngle = 0;
        
        _translationThresholdPassed = NO;
        _rotationThresholdPassed = NO;
        _scaleThresholdPassed = NO;
        
        NSArray *touchArr = [touches allObjects];
        if (touchArr.count >= 2) {
            _firstTouch = touchArr[0];
            _secondTouch = touchArr[1];
            
            CGPoint firstTouchPoint = [_firstTouch locationInView:secneView];
            CGPoint secondTouchPoint = [_secondTouch locationInView:secneView];
            _initialMidPoint = [SGARGestureHandler getMidPoint:firstTouchPoint second:secondTouchPoint];
            
            CGPoint thirdCorner = CGPointMake(firstTouchPoint.x, secondTouchPoint.y);
            CGPoint fourthCorner = CGPointMake(secondTouchPoint.x, firstTouchPoint.y);

            NSArray *midPoints = @[[NSValue valueWithCGPoint:[SGARGestureHandler getMidPoint:thirdCorner second:firstTouchPoint]],
                                   [NSValue valueWithCGPoint:[SGARGestureHandler getMidPoint:thirdCorner second:secondTouchPoint]],
                                   [NSValue valueWithCGPoint:[SGARGestureHandler getMidPoint:fourthCorner second:firstTouchPoint]],
                                   [NSValue valueWithCGPoint:[SGARGestureHandler getMidPoint:fourthCorner second:secondTouchPoint]],
                                   [NSValue valueWithCGPoint:[SGARGestureHandler getMidPoint:_initialMidPoint second:firstTouchPoint]],
                                   [NSValue valueWithCGPoint:[SGARGestureHandler getMidPoint:_initialMidPoint second:secondTouchPoint]],
                                   [NSValue valueWithCGPoint:[SGARGestureHandler getMidPoint:_initialMidPoint second:thirdCorner]],
                                   [NSValue valueWithCGPoint:[SGARGestureHandler getMidPoint:_initialMidPoint second:fourthCorner]],
                                   ];
            
            NSMutableArray *allPoints = [NSMutableArray arrayWithArray:@[[NSValue valueWithCGPoint:firstTouchPoint],
                                                                         [NSValue valueWithCGPoint:secondTouchPoint],
                                                                         [NSValue valueWithCGPoint:thirdCorner],
                                                                         [NSValue valueWithCGPoint:fourthCorner]]];
            [allPoints addObjectsFromArray:midPoints];
            
            [allPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGPoint point = [obj CGPointValue];
                SGARObject *object = [self virtualObjectAtPoint:point];
                if (object) {
                    _firstTouchedObject = object;
                    *stop = YES;
                }
            }];
            
            if (_firstTouchedObject) {
                
                objectBaseScale = _firstTouchedObject.scale.x;
                
                allowTranslation = YES;
                allowRotation = YES;
                
                initialDistanceBetweenFingers = [SGARGestureHandler distanceFrom:firstTouchPoint toPoint:secondTouchPoint];
                
                initialFingerAngle = atan2(_initialMidPoint.x, _initialMidPoint.y);
                initialObjectAngle = _firstTouchedObject.eulerAngles.y;
            } else {
                allowTranslation = NO;
                allowRotation = NO;
            }
        }
    }
    return self;
}

- (void)updateGesture {
    
    [super updateGesture];
    
    if (!_firstTouchedObject) return;

    
    NSArray *touchArr = [self.currentTouches allObjects];
    if (touchArr.count >= 2) {
        UITouch *newFirstTouch = touchArr[0];
        UITouch *newSecondTouch = touchArr[1];

        if ([newFirstTouch isEqual:_firstTouch]) {
            _firstTouch = newFirstTouch;
            _secondTouch = newSecondTouch;
        } else {
            _firstTouch = newSecondTouch;
            _secondTouch = newFirstTouch;
        }
        
        CGPoint loc1 = [_firstTouch locationInView:self.sceneView];
        CGPoint loc2 = [_secondTouch locationInView:self.sceneView];
        
        if (allowTranslation) {
            [self updateTranslationObject:_firstTouchedObject withMidPoint:[SGARGestureHandler getMidPoint:loc1 second:loc2]];
        }
        
        CGPoint spanBetweenTouches = CGPointMake(loc1.x - loc2.x,
                                                 loc1.y - loc2.y);
        if (allowRotation) {
            [self updateRotationObject:_firstTouchedObject spanPoint:spanBetweenTouches];
        }
    }
  
}


- (void)updateTranslationObject:(SGARObject *)arObject withMidPoint:(CGPoint)midPoint {

    if (!_translationThresholdPassed) {
        CGFloat distanceFromStartLocation = [SGARGestureHandler distanceFrom:midPoint toPoint:_initialMidPoint];
        
        CGFloat threshold = translationThreshold;
        
        if (_rotationThresholdPassed || _scaleThresholdPassed) {
            threshold = translationThresholdHarder;
        }
        
        if (distanceFromStartLocation >= threshold) {
            
            _translationThresholdPassed = YES;
            
            
            SCNVector3 currentObjectLocation = [self.sceneView projectPoint:_firstTouchedObject.position];
            
            dragOffset = CGPointMake(midPoint.x - currentObjectLocation.x,
                                     midPoint.y - currentObjectLocation.y);
        }
    }
    
    if (_translationThresholdPassed) {
        CGPoint offsetPos = CGPointMake(midPoint.x - dragOffset.x,
                                        midPoint.y - dragOffset.y);
        [self.objectManager translate:arObject
                          inSceneView:self.sceneView
                               baseOn:offsetPos
                            instantly:NO
                        infinitePlane:YES];
        self.lastUsedObject = arObject;
    }
}

- (void)updateRotationObject:(SGARObject *)arObject spanPoint:(CGPoint)spanPoint {
    
    CGPoint midpointToFirstTouch = CGPointMake(spanPoint.x / 2, spanPoint.y / 2);
    
    CGFloat currentAngle = atan2(midpointToFirstTouch.x, midpointToFirstTouch.y);
    
    CGFloat currentAngleToInitialFingerAngle = initialFingerAngle - currentAngle;
    
    if (!_rotationThresholdPassed) {
        
        CGFloat threshold = rotationThreshold;

        if (_translationThresholdPassed || _scaleThresholdPassed) {
            threshold = rotationThresholdHarder;
        }
        
        if (fabs(currentAngleToInitialFingerAngle) > threshold) {
            
            _rotationThresholdPassed = YES;
            
            if (currentAngleToInitialFingerAngle > 0) {
                initialObjectAngle += threshold;
            } else {
                initialObjectAngle -= threshold;
            }
        }
    }
    
    if (_rotationThresholdPassed) {
        arObject.eulerAngles = SCNVector3Make(arObject.eulerAngles.x, initialObjectAngle - currentAngleToInitialFingerAngle, arObject.eulerAngles.z);
        self.lastUsedObject = arObject;
    }
}



@end
