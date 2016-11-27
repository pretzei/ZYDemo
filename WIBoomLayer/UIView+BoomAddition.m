//
//  UIView+BoomAddition.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/26.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "UIView+BoomAddition.h"
#import "UIImage+BoomAddition.h"
#import <objc/runtime.h>
#import "WIBoomLayer.h"

@interface UIView (BoomAdditionPrivate)

@property (strong, nonatomic) UIImage *snapShot;

@end

static NSString * const kSNAPSHOT = @"WISNAPSHOT";

@implementation UIView (BoomAddition)

- (UIImage *)snapShot {
    return objc_getAssociatedObject(self, &kSNAPSHOT);
}

- (void)setSnapShot:(UIImage *)snapShot {
    objc_setAssociatedObject(self, &kSNAPSHOT, snapShot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)explodeWithSize:(CGFloat)size point:(CGPoint)point {
    NSInteger num = 16;
    for (NSInteger i = 0; i < num; i++) {
        for (NSInteger j = 0; j < num; j++) {
            if (self.snapShot == nil) {
                self.snapShot = [[self snapshotImage] scaleImageToSize:CGSizeMake(32, 32)];
            }
            UIColor *color = [self.snapShot pixelColorWithPoint:CGPointMake(i * 2, j * 2)];
            
            WIBoomLayer *layer = [[WIBoomLayer alloc] initWithPoint:point size:size color:color perSize:size / num];
            [self.layer addSublayer:layer];
            [layer explode];
        }
    }
}


- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

@end
