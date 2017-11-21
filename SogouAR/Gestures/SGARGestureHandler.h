//
//  SGARGestureHandler.h
//  SogouAR
//
//  Created by fk on 2017/11/17.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import "SGARObjectManager.h"

typedef NS_ENUM(NSInteger, TouchEventType) {
    TouchEventBegan,
    TouchEventeMoved,
    TouchEventEnded,
    TouchEventCancelled
};

@interface SGARGestureHandler : NSObject

@property (nonatomic, strong) ARSCNView *sceneView;

@property (nonatomic, strong) SGARObject *lastUsedObject;
@property (nonatomic, strong) SGARObjectManager *objectManager;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) NSMutableSet <UITouch *>*currentTouches;


+ (CGFloat)distanceFrom:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
+ (CGPoint)getMidPoint:(CGPoint)firstPoint second:(CGPoint)secondPoint;

+ (SGARGestureHandler *)fetchGestureFromTouches:(NSSet <UITouch *>*)touches
                                      sceneView:(ARSCNView *)secneView
                                 lastUsedObject:(SGARObject *)lastUsedObject
                                  objectManager:(SGARObjectManager *)objectManager;



- (instancetype)initWithTouches:(NSSet <UITouch *>*)touches
                      sceneView:(ARSCNView *)secneView
                 lastUsedObject:(SGARObject *)lastUsedObject
                  objectManager:(SGARObjectManager *)objectManager;

- (SGARGestureHandler *)updateGestureFromTouches:(NSSet <UITouch *>*)touches touchType:(TouchEventType)type;

- (void)updateGesture;
- (void)finishGesture;

- (SGARObject *)virtualObjectAtPoint:(CGPoint)point;




@end
