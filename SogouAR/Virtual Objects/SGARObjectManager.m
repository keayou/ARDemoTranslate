//
//  SGARObjectManager.m
//  SogouAR
//
//  Created by fk on 2017/11/17.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "SGARObjectManager.h"
#import "SogouAR-Swift.h"
#import "SGARGestureHandler.h"

@interface SGARObjectManager ()

@property (nonatomic, weak) dispatch_queue_t updateQueue;

@property (nonatomic, strong) SGARGestureHandler *currentGesture;

@end

@implementation SGARObjectManager

- (instancetype)initWithQueue:(dispatch_queue_t)updateQueue {
    
    self = [super init];
    if (self) {
     
        self.virtualObjects = [NSMutableArray array];
        
        self.updateQueue = updateQueue;
    }
    return self;
}


#pragma mark - Public
#pragma mark -- Resetting objects
- (void)removeAllVirtualObjects {
    
    [self.virtualObjects enumerateObjectsUsingBlock:^(SGARObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self unloadVirtualObject:obj];
    }];
    [self.virtualObjects removeAllObjects];
}


- (BOOL)removeVirtualObject:(SGARObject *)arObject {
    if ([self.virtualObjects containsObject:arObject]) {
        [self unloadVirtualObject:arObject];
        [self.virtualObjects removeObject:arObject];
        return YES;
    }
    return NO;
}


#pragma mark -- Loading object
- (void)loadVirtualObject:(SGARObject *)arObject toPostion:(SCNVector3)position cameraTransform:(matrix_float4x4)cameraTransform {
    
    [self.virtualObjects addObject:arObject];
    
    if (_delegate && [_delegate respondsToSelector:@selector(arObjectManagerWillLoad:)]) {
        [_delegate arObjectManagerWillLoad:arObject];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       
        [arObject load];
        
        dispatch_async(self.updateQueue, ^{
        
            [self setNewVirtualObjectPosition:arObject toPostion:position cameraTransform:cameraTransform];
            self.lastUsedObject = arObject;
            
            if (_delegate && [_delegate respondsToSelector:@selector(arObjectManagerDidLoad:)]) {
                [_delegate arObjectManagerDidLoad:arObject];
            }
        });
    });
}

#pragma mark -- React to gestures
- (void)reactToTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inSceneView:(ARSCNView *)sceneView {
    
    if (self.virtualObjects.count <= 0) return;

    if (_currentGesture == nil) {
        _currentGesture = [SGARGestureHandler fetchGestureFromTouches:touches sceneView:sceneView lastUsedObject:self.lastUsedObject objectManager:self];
        if (_currentGesture && _currentGesture.lastUsedObject) {
            self.lastUsedObject = _currentGesture.lastUsedObject;
        }
    } else {
        _currentGesture = [_currentGesture updateGestureFromTouches:touches touchType:TouchEventBegan];
        if (_currentGesture && _currentGesture.lastUsedObject) {
            self.lastUsedObject = _currentGesture.lastUsedObject;
        }
    }
}


- (void)reactToTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.virtualObjects.count <= 0) return;

    _currentGesture = [_currentGesture updateGestureFromTouches:touches touchType:TouchEventeMoved];
    if (_currentGesture && _currentGesture.lastUsedObject) {

        self.lastUsedObject = _currentGesture.lastUsedObject;
        if (_delegate && [_delegate respondsToSelector:@selector(arObjectManagerTransformDidChangeFor:)]) {
            [_delegate arObjectManagerTransformDidChangeFor:self.lastUsedObject];
        }
    }
}

- (void)reactToTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.virtualObjects.count <= 0) return;
    _currentGesture = [_currentGesture updateGestureFromTouches:touches touchType:TouchEventEnded];
    if (_currentGesture && _currentGesture.lastUsedObject) {
        self.lastUsedObject = _currentGesture.lastUsedObject;
        if (_delegate && [_delegate respondsToSelector:@selector(arObjectManagerTransformDidChangeFor:)]) {
            [_delegate arObjectManagerTransformDidChangeFor:self.lastUsedObject];
        }
    }
    
}
- (void)reactToTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (self.virtualObjects.count <= 0) return;
    _currentGesture = [_currentGesture updateGestureFromTouches:touches touchType:TouchEventCancelled];
}

#pragma mark -- Update object position
- (void)translate:(SGARObject *)arObject
      inSceneView:(ARSCNView *)scnView
           baseOn:(CGPoint)screenPos
        instantly:(BOOL)instantly
    infinitePlane:(BOOL)infinitePlane {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        SCNVector3 arObjectSimdPosition = SCNVector3Make(arObject.simdPosition.x,
                                                         arObject.simdPosition.y,
                                                         arObject.simdPosition.z);
        ScreenPositionResultOC *positionResult = [scnView worldPositionFromScreenPosition:screenPos :arObjectSimdPosition :infinitePlane];
        
        SCNVector3 newPosition = positionResult.position;
        
        matrix_float4x4 cameraTransform = scnView.session.currentFrame.camera.transform;
        
        dispatch_async(self.updateQueue, ^{
            [self setPositionForObject:arObject
                              position:newPosition
                             instantly:instantly
                        filterPosition:!positionResult.hitAPlane
                       cameraTransform:cameraTransform];
        });
    });
}


#pragma mark - Private
- (void)unloadVirtualObject:(SGARObject *)arObject {
    dispatch_async(self.updateQueue, ^{
        
        [arObject unload];
        [arObject removeFromParentNode];
        if (self.lastUsedObject == arObject) {
            self.lastUsedObject = nil;
            if (self.virtualObjects.count > 1) {
                self.lastUsedObject = self.virtualObjects[0];
            }
        }
    });
}


- (void)setPositionForObject:(SGARObject *)arObject
                    position:(SCNVector3)position
                   instantly:(BOOL)instantly
              filterPosition:(BOOL)filterPosition
             cameraTransform:(matrix_float4x4)cameraTransform {
    
    if (instantly) {
        [self setNewVirtualObjectPosition:arObject toPostion:position cameraTransform:cameraTransform];
    } else {
        [self updateVirtualObjectPosition:arObject toPostion:position filterPosition:filterPosition cameraTransform:cameraTransform];
    }
    
}

- (void)setNewVirtualObjectPosition:(SGARObject *)arObject toPostion:(SCNVector3)position cameraTransform:(matrix_float4x4)cameraTransform {
    
    SCNVector3 cameraWorldPos = SCNVector3Make(cameraTransform.columns[3].x,
                                               cameraTransform.columns[3].y,
                                               cameraTransform.columns[3].z);
    
    simd_float3 cameraToPosition = simd_make_float3(position.x - cameraWorldPos.x,
                                                    position.y - cameraWorldPos.y,
                                                    position.z - cameraWorldPos.z);
    
    if (simd_length(cameraToPosition) > 10) {
        cameraToPosition = simd_normalize(cameraToPosition);
        cameraToPosition *= 10;
    }
    arObject.simdPosition = simd_make_float3(cameraWorldPos.x + cameraToPosition.x,
                                             cameraWorldPos.y + cameraToPosition.y,
                                             cameraWorldPos.z + cameraToPosition.z);
    
    [arObject.recentVirtualObjectDistances removeAllObjects];
}

- (void)updateVirtualObjectPosition:(SGARObject *)arObject
                          toPostion:(SCNVector3)position
                     filterPosition:(BOOL)filterPosition
                    cameraTransform:(matrix_float4x4)cameraTransform {
    
    SCNVector3 cameraWorldPos = SCNVector3Make(cameraTransform.columns[3].x,
                                               cameraTransform.columns[3].y,
                                               cameraTransform.columns[3].z);

    simd_float3 cameraToPosition = simd_make_float3(position.x - cameraWorldPos.x,
                                                    position.y - cameraWorldPos.y,
                                                    position.z - cameraWorldPos.z);

    if (simd_length(cameraToPosition) > 10) {
        cameraToPosition = simd_normalize(cameraToPosition);
        cameraToPosition *= 10;
    }
    
    // Compute the average distance of the object from the camera over the last ten
    // updates. If filterPosition is true, compute a new position for the object
    // with this average. Notice that the distance is applied to the vector from
    // the camera to the content, so it only affects the percieved distance of the
    // object - the averaging does _not_ make the content "lag".
    float hitTestResultDistance = simd_length(cameraToPosition);
    [arObject.recentVirtualObjectDistances addObject:[NSNumber numberWithFloat:hitTestResultDistance]];
    NSInteger count = arObject.recentVirtualObjectDistances.count - 10;
    if (count > 0) {
        for (int idx = 0; idx < count; idx++) {
            [arObject.recentVirtualObjectDistances removeObjectAtIndex:0];
        }
    }
    
    if (filterPosition) {
        
        float sum = 0;
        for (int idx = 0; idx < arObject.recentVirtualObjectDistances.count; idx++) {
            sum += [arObject.recentVirtualObjectDistances[idx] floatValue];
        }

        float averageDistance = sum / arObject.recentVirtualObjectDistances.count;

        simd_float3 normalizePos = simd_normalize(cameraToPosition) * averageDistance;
//        normalizePos = simd_make_float3(normalizePos.x * averageDistance,
//                                        normalizePos.y * averageDistance,
//                                        normalizePos.z * averageDistance);
        simd_float3 averagedDistancePos = simd_make_float3(cameraWorldPos.x + normalizePos.x,
                                                           cameraWorldPos.y + normalizePos.y,
                                                           cameraWorldPos.z + normalizePos.z);
        [arObject setSimdPosition:averagedDistancePos];
    } else {
        
        simd_float3 simdPosition = simd_make_float3(cameraWorldPos.x + cameraToPosition.x,
                                                    cameraWorldPos.y + cameraToPosition.y,
                                                    cameraWorldPos.z + cameraToPosition.z);
        [arObject setSimdPosition:simdPosition];
    }
}





@end
