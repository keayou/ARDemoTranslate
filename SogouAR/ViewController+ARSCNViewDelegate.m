//
//  ViewController+ARSCNViewDelegate.m
//  ARWangZai
//
//  Created by fk on 2017/10/24.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "ViewController+ARSCNViewDelegate.h"

@implementation ViewController (ARSCNViewDelegate)
#pragma mark - ARSCNViewDelegate
// Override to create and configure nodes for anchors added to the view's session.
//- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
//    SCNNode *node = [SCNNode new];
//    return node;
//}

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
//    if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {
//        NSLog(@"didAddNode -- anchor.id = %@",anchor.identifier);
//
//        dispatch_async(self.serialQueue, ^{
//
//            ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
//
//            SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x height:0 length:planeAnchor.extent.z chamferRadius:0];
////                plane.firstMaterial.diffuse.contents = [UIColor redColor];
//
//            SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
//
//            planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
//
//            //    planeNode.physicsBody = [SCNPhysicsBody
//            //                             bodyWithType:SCNPhysicsBodyTypeKinematic
//            //                             shape: [SCNPhysicsShape shapeWithGeometry:plane options:nil]];
//
//            [node addChildNode:planeNode];
//
//            [self.planeDict setObject:planeNode forKey:planeAnchor.identifier];
//
//
//        });
//    }
}

- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    dispatch_async(self.serialQueue, ^{
//
//        NSLog(@"UpdateNode -- anchor.id = %@",anchor.identifier);
//
//        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
//
//        SCNNode *planeNode = [self.planeDict objectForKey:planeAnchor.identifier];
//        if (!planeNode) return;
//
//        SCNBox *box = (SCNBox *)planeNode.geometry;
//        box.width = planeAnchor.extent.x;
//        box.height = 0;
//        box.length = planeAnchor.extent.z;
//        planeNode.position =SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
//
//    });
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    NSLog(@"RemoveNode -- anchor.id = %@",anchor.identifier);
    
    [self.planeDict removeObjectForKey:anchor.identifier];
}


- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    
    [self updateFocusSquare];
    
//    ARLightEstimate *lightEstimate = self.arSession.currentFrame.lightEstimate;
////    if (lightEstimate) {
////        [self.arSCNView.scene enableEnvironmentMapWithIntensity:lightEstimate.ambientIntensity / 40 queue:self.serialQueue];
////    } else {
////        [self.arSCNView.scene enableEnvironmentMapWithIntensity:40 queue:self.serialQueue];
////    }
//
////    NSLog(@"ambientIntensity --- :%f",lightEstimate.ambientIntensity);
//    self.arSCNView.scene.lightingEnvironment.intensity = lightEstimate.ambientIntensity / 1000;
}

- (void)updateFocusSquare {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __block BOOL objectVisible = NO;
        [self.objectManager.virtualObjects enumerateObjectsUsingBlock:^(SGARObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.arSCNView isNodeInsideFrustum:(SCNNode *)obj withPointOfView:self.arSCNView.pointOfView]) {
                objectVisible = YES;
                *stop = YES;
            }
        }];
        if (objectVisible) {
            [self.focusSquare hide];
        } else {
            [self.focusSquare unhide];
        }
        
        CGPoint viewCenter = self.arSCNView.center;
        ScreenPositionResultOC *positionResult = [self.arSCNView worldPositionFromScreenPosition:viewCenter :self.focusSquare.position :NO];
        dispatch_async(self.serialQueue, ^{
            self.focusSquareLastPos = positionResult.position;
            [self.focusSquare updateFor:positionResult.position planeAnchor:positionResult.planeAnchor camera:self.arSCNView.session.currentFrame.camera];
        });
    });
}
@end
