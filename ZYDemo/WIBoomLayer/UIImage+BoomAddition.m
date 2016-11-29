//
//  UIImage+BoomAddition.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/26.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "UIImage+BoomAddition.h"

@implementation UIImage (BoomAddition)

- (UIImage *)scaleImageToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

- (UIColor *)pixelColorWithPoint:(CGPoint)point {
    CGDataProviderRef dataProvider = CGImageGetDataProvider(self.CGImage);
    CFDataRef dataRef = CGDataProviderCopyData(dataProvider);
    const UInt8 *data = CFDataGetBytePtr(dataRef);
    NSInteger pixelInfo = (NSInteger)((self.size.width * point.y + point.x) * 4);
    CGFloat red = (CGFloat)data[pixelInfo] / 255;
    CGFloat green = (CGFloat)data[pixelInfo + 1] / 255;
    CGFloat blue = (CGFloat)data[pixelInfo + 2] / 255;
    CGFloat alpha = (CGFloat)data[pixelInfo + 3] /255;
    free((void *)dataRef);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
