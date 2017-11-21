//
//  FeatureHitTestResultOC.m
//  ARWangZai
//
//  Created by fk on 2017/11/3.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "FeatureHitTestResultOC.h"

@implementation FeatureHitTestResultOC


- (instancetype)initWithPosition:(SCNVector3)position
             distanceToRayOrigin:(float)distanceToRayOrigin
                      featureHit:(SCNVector3)featureHit
      featureDistanceToHitResult:(float)featureDistanceToHitResult {
    
    self = [super init];
    if (self) {
        _position = position;
        _distanceToRayOrigin = distanceToRayOrigin;
        _featureHit = featureHit;
        _featureDistanceToHitResult = featureDistanceToHitResult;
    }
    return self;
    
    
}
@end
