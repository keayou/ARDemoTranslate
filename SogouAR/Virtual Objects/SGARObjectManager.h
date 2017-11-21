//
//  SGARObjectManager.h
//  SogouAR
//
//  Created by fk on 2017/11/17.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>

#import "SGARObject.h"

@protocol SGARObjectManagerDelegate <NSObject>

- (void)arObjectManagerWillLoad:(SGARObject *)virtualObject;

- (void)arObjectManagerDidLoad:(SGARObject *)virtualObject;

- (void)arObjectManagerCouldNotPlace:(SGARObject *)virtualObject;

- (void)arObjectManagerTransformDidChangeFor:(SGARObject *)virtualObject;


@end


@interface SGARObjectManager : NSObject

@property (nonatomic, weak) id<SGARObjectManagerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray <SGARObject *>*virtualObjects;

@property (nonatomic, strong) SGARObject *lastUsedObject;


- (instancetype)initWithQueue:(dispatch_queue_t)updateQueue;


- (void)loadVirtualObject:(SGARObject *)arObject
                toPostion:(SCNVector3)position
          cameraTransform:(matrix_float4x4)cameraTransform;


- (void)translate:(SGARObject *)arObject
      inSceneView:(ARSCNView *)scnView
           baseOn:(CGPoint)screenPos
        instantly:(BOOL)instantly
    infinitePlane:(BOOL)infinitePlane;

- (void)reactToTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inSceneView:(ARSCNView *)sceneView;
- (void)reactToTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)reactToTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)reactToTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)even;

@end
