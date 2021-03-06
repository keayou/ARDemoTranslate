//
//  SGTextNode.m
//  SogouAR
//
//  Created by fk on 2017/11/6.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "SGTextNode.h"

@interface SGTextNode ()

@property (nonatomic, strong) NSString *text;


@end


@implementation SGTextNode

- (instancetype) initWithText:(NSString *)text {
    
    self = [super init];
    if (self) {
        [self updateTextContent:text];
    }
    return self;
}

- (void)updateTextContent:(NSString *)text {
    
    _text = text;
    
    CGFloat bubbleDepth = 0.01;
    
    SCNText *textGeo = [SCNText textWithString:text extrusionDepth:bubbleDepth];
    
    textGeo.font = [self getTextFont];//[UIFont systemFontOfSize:0.15];
    textGeo.alignmentMode = kCAAlignmentCenter;
    textGeo.firstMaterial.diffuse.contents = [UIColor orangeColor];
    textGeo.firstMaterial.specular.contents = [UIColor whiteColor];
    textGeo.firstMaterial.doubleSided = YES;
//    textGeo.chamferRadius = bubbleDepth;

    SCNVector3 minBound,maxBound;
    [textGeo getBoundingBoxMin:&minBound max:&maxBound];
    
    SCNNode *textNode = [SCNNode nodeWithGeometry:textGeo];
    textNode.pivot = SCNMatrix4MakeTranslation( (maxBound.x - minBound.x)/2, minBound.y, bubbleDepth/2);
    textNode.scale = SCNVector3Make(0.2, 0.2, 0.2);
    
    _textHeight = minBound.y;
    
    SCNSphere *sphere = [SCNSphere sphereWithRadius:0.005];
    sphere.firstMaterial.diffuse.contents = [UIColor redColor];
    SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
    sphereNode.position = SCNVector3Make(0, 0, 0);
//    [textNode addChildNode:sphereNode];
    
    SCNBillboardConstraint *billboardConstraint = [SCNBillboardConstraint billboardConstraint];
    billboardConstraint.freeAxes = SCNBillboardAxisY;

  
    [self addChildNode:textNode];
//    [textNode addChildNode:sphereNode];
    self.constraints = @[billboardConstraint];
}

- (UIFont *)getTextFont {
    
    return [UIFont fontWithName:@"TrebuchetMS-Bold" size:0.15];
    
    
}

@end
