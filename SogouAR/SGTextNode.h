//
//  SGTextNode.h
//  SogouAR
//
//  Created by fk on 2017/11/6.
//  Copyright © 2017年 fk. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface SGTextNode : SCNNode
- (instancetype) initWithText:(NSString *)text;

@property (nonatomic, assign) CGFloat textHeight;

@end
