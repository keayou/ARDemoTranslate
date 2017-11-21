//
//  FeatureHitTestResultOC.h
//  ARWangZai
//
//  Created by fk on 2017/11/3.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface FeatureHitTestResultOC : NSObject

@property (nonatomic, assign) SCNVector3 position;

@property (nonatomic, assign) float distanceToRayOrigin;

@property (nonatomic, assign) SCNVector3 featureHit;

@property (nonatomic, assign) float featureDistanceToHitResult;

- (instancetype)initWithPosition:(SCNVector3)position
             distanceToRayOrigin:(float)distanceToRayOrigin
                      featureHit:(SCNVector3)featureHit
      featureDistanceToHitResult:(float)featureDistanceToHitResult;

@end
