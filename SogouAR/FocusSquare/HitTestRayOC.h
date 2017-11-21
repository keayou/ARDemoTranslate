//
//  HitTestRayOC.h
//  ARWangZai
//
//  Created by fk on 2017/11/3.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface HitTestRayOC : NSObject

@property (nonatomic, assign) SCNVector3 origin;
@property (nonatomic, assign) SCNVector3 direction;

- (instancetype)initWithOrigin:(SCNVector3)origin direction:(SCNVector3)direction;


@end
