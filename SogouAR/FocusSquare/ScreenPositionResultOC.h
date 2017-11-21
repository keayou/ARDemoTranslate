//
//  ScreenPositionResultOC.h
//  ARWangZai
//
//  Created by fk on 2017/11/3.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface ScreenPositionResultOC : NSObject
//let position: SCNVector3
//let planeAnchor: ARPlaneAnchor
//let hitAPlane: Bool

@property (nonatomic, assign) SCNVector3 position;
@property (nonatomic, strong) ARPlaneAnchor *planeAnchor;
@property (nonatomic, assign) BOOL hitAPlane;

- (instancetype)initWithPosition:(SCNVector3)position planeAnchor:(ARPlaneAnchor *)planeAnchor hitAPlane:(BOOL)hitAPlane;

@end
