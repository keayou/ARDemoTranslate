//
//  ViewController.h
//  SogouAR
//
//  Created by fk on 2017/11/6.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

#import "SogouAR-Swift.h"

#import "SGARObjectManager.h"

@interface ViewController : UIViewController<ARSCNViewDelegate,ARSessionDelegate,SCNSceneRendererDelegate,SGARObjectManagerDelegate>

@property (nonatomic, strong) NSMutableDictionary *planeDict;

@property(nonatomic, strong) dispatch_queue_t serialQueue;

@property(nonatomic, strong) ARSCNView *arSCNView;

@property(nonatomic, strong) ARSession *arSession;

@property (nonatomic, strong) FocusSquare *focusSquare;
@property (nonatomic, assign) SCNVector3 focusSquareLastPos;

@property (nonatomic, strong) SGARObjectManager *objectManager;

//private
- (void)updateTextManagerInfo:(NSString *)text;


@end

