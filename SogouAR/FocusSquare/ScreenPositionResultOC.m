//
//  ScreenPositionResultOC.m
//  ARWangZai
//
//  Created by fk on 2017/11/3.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "ScreenPositionResultOC.h"

@implementation ScreenPositionResultOC

- (instancetype)initWithPosition:(SCNVector3)position planeAnchor:(ARPlaneAnchor *)planeAnchor hitAPlane:(BOOL)hitAPlane {
    
    self = [super init];
    if (self) {
        _position = position;
        _planeAnchor = planeAnchor;
        _hitAPlane = hitAPlane;
    }
    return self;
    
}

@end
