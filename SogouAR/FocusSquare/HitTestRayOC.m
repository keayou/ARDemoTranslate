//
//  HitTestRayOC.m
//  ARWangZai
//
//  Created by fk on 2017/11/3.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "HitTestRayOC.h"

@implementation HitTestRayOC
- (instancetype)initWithOrigin:(SCNVector3)origin direction:(SCNVector3)direction {
    self = [super init];
    if (self) {
        _origin = origin;
        _direction = direction;
    }
    return self;
}
@end
