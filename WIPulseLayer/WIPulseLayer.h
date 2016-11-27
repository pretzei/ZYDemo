//
//  WIPulseLayer.h
//  WIInputMethod
//
//  Created by wilab-pretzei on 16/9/26.
//  Copyright © 2016年 wilab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

static const CGFloat kSIZE = 30.f;
static const float kDURATION = 0.5f;

@interface WIPulseLayer : CALayer

+ (void)pulseInView:(UIView *)view point:(CGPoint)point color:(UIColor *)color size:(CGFloat)size;

@end
