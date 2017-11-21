//
//  ViewController+ARSessionDelegate.m
//  ARWangZai
//
//  Created by fk on 2017/10/24.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "ViewController+ARSessionDelegate.h"

@implementation ViewController (ARSessionDelegate)
- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera {
    NSString *cametaStateStr = nil;
    switch (camera.trackingState) {
        case ARTrackingStateNotAvailable:
            cametaStateStr = @"初始化...";
            break;
        case ARTrackingStateNormal:
            cametaStateStr = @"Working";
            break;
        case ARTrackingStateLimited:
        {
            switch (camera.trackingStateReason) {
                case ARTrackingStateReasonNone:
                    cametaStateStr = @"Working";
                    break;
                case ARTrackingStateReasonInitializing:
                    cametaStateStr = @"正在初始化...";
                    break;
                case ARTrackingStateReasonExcessiveMotion:
                    cametaStateStr = @"设备移动过快，无法正常追踪";
                    break;
                case ARTrackingStateReasonInsufficientFeatures:
                    cametaStateStr = @"特征过少，无法正常追踪";
                    break;
            }
            break;
        }
    }
    [self updateTextManagerInfo:cametaStateStr];
}



- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}
@end
