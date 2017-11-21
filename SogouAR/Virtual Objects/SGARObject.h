//
//  SGARObject.h
//  SogouAR
//
//  Created by fk on 2017/11/17.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface SGARObject : SCNReferenceNode

@property (nonatomic, strong) NSMutableArray *recentVirtualObjectDistances;   //Max Count = 10

+ (SGARObject *)isNodePartOfARObject:(SCNNode *)node;

//- (instancetype)initWithURL:(NSURL *)referenceURL;
@end
