//
//  WIBoomLayer.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/27.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "WIBoomLayer.h"

@interface WIBoomLayer () <CAAnimationDelegate> {
    CGFloat _size;
    CGPoint _point;
}

@end

@implementation WIBoomLayer

- (instancetype)initWithPoint:(CGPoint)point size:(CGFloat)size color:(UIColor *)color perSize:(CGFloat)pSize {
    if (self = [super init]) {
        self.backgroundColor = color.CGColor;
        self.opacity = 1;
        self.cornerRadius = pSize / 2;
        self.frame = CGRectMake(point.x - pSize / 2, point.y - pSize / 2, pSize, pSize);
        self.position = point;
        _size = size;
        _point = point;
    }
    return self;
}

- (void)explode {
    CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    moveAnimation.path = [self makeRandomPathWithPoint:_point size:_size].CGPath;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.240000: 0.590000: 0.506667: 0.026667];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = @(1 - 0.7 * ((arc4random() % 61)/ 50));
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1;
    opacityAnimation.toValue = @0;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.380000: 0.033333: 0.963333: 0.260000];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = (arc4random() % 10) * 0.05 + 0.3;
    animationGroup.removedOnCompletion = NO;
    animationGroup.animations = @[moveAnimation, scaleAnimation, opacityAnimation];
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.delegate = self;
    
    [self addAnimation:animationGroup forKey:@"animitions"];

}

- (UIBezierPath *)makeRandomPathWithPoint:(CGPoint)point size:(CGFloat)size {
    UIBezierPath *particlePath = [UIBezierPath bezierPath];
    [particlePath moveToPoint:point];
    CGFloat basicLeft = -(size);
    CGFloat maxOffset = 2.0 * fabs(basicLeft);
    NSInteger randomNumber = arc4random()%101;
    CGFloat endPointX = basicLeft + maxOffset * (1.0*randomNumber/100) + point.x;
    CGFloat controlPointOffSetX = (endPointX - point.x)/2  + point.x;
    CGFloat controlPointOffSetY = point.y - 0.2 * size - (arc4random() % (int)(1.2 * size));
    CGFloat endPointY = point.y + size / 2 + (arc4random() % (int)(size / 2));
    [particlePath addQuadCurveToPoint:CGPointMake(endPointX, endPointY) controlPoint:CGPointMake(controlPointOffSetX, controlPointOffSetY)];
    return particlePath;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([anim isKindOfClass:[CAAnimationGroup class]] && flag) {
        [self removeAllAnimations];
        [self removeFromSuperlayer];
    }
}

- (void)dealloc {
    
}

@end
