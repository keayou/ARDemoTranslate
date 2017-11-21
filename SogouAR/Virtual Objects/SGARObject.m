//
//  SGARObject.m
//  SogouAR
//
//  Created by fk on 2017/11/17.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "SGARObject.h"

@implementation SGARObject

+ (SGARObject *)isNodePartOfARObject:(SCNNode *)node {
    
    if ([node isKindOfClass:[SGARObject class]]) {
        return (SGARObject *)node;
    }
    
    if (node.parentNode != nil) {
        return [[self class] isNodePartOfARObject:node.parentNode];
    }
    return nil;
}

- (instancetype)initWithURL:(NSURL *)referenceURL {
    
    self = [super initWithURL:referenceURL];
    if (self) {
        _recentVirtualObjectDistances = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

@end
