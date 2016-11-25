//
//  WIPulseLayer.m
//  WIInputMethod
//
//  Created by wilab-pretzei on 16/9/26.
//  Copyright © 2016年 wilab. All rights reserved.
//

#import "WIPulseLayer.h"

static NSString * const SCALE = @"transform.scale";
static NSString * const OPACITY = @"opacity";
static NSString * const DIFFUSEKEY = @"diffuse";

@interface WIPulseLayer () <CAAnimationDelegate>

@end

@implementation WIPulseLayer

- (instancetype)initWithPoint:(CGPoint)point color:(UIColor *)color size:(CGFloat)size {
    if (self = [super init]) {
        self.frame = CGRectMake(point.x - size/2, point.y - size/2, size, size);
        self.cornerRadius = size / 2;
        self.opacity = 0;
        self.contentsScale = [UIScreen mainScreen].scale;
        self.backgroundColor = [color CGColor];
        
        self.shadowColor = [UIColor blackColor].CGColor;
        self.shadowRadius = size / 10;
        self.shadowOpacity = 0.6;
        self.shadowOffset = CGSizeMake(0, 3);
    }
    return self;
}

+ (instancetype)layerWithPoint:(CGPoint)point color:(UIColor *)color size:(CGFloat)size {
    return [[self alloc] initWithPoint:point color:color size:size];
}

+ (void)pulseInView:(UIView *)view point:(CGPoint)point color:(UIColor *)color size:(CGFloat)size {
    WIPulseLayer *pulseLayer = [WIPulseLayer layerWithPoint:point color:color size:size];
    [view.layer addSublayer:pulseLayer];
    [pulseLayer diffuse];
}

- (void)diffuse {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = kDURATION;
        animationGroup.repeatCount = 0;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:SCALE];
        scaleAnimation.fromValue = @0.0;
        scaleAnimation.toValue = @1.0;
        scaleAnimation.duration = kDURATION;
        
        CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:OPACITY];
        opacityAnimation.duration = kDURATION;
        opacityAnimation.values = @[@0.6, @0.45, @0];
        opacityAnimation.keyTimes = @[@0, @0.2, @1];
        
        NSArray *animations = @[scaleAnimation, opacityAnimation];
        
        animationGroup.animations = animations;
        animationGroup.delegate = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addAnimation:animationGroup forKey:DIFFUSEKEY];
        });
    });
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([anim isKindOfClass:[CAAnimationGroup class]] && flag) {
        [self removeFromSuperlayer];
    }
}

@end
