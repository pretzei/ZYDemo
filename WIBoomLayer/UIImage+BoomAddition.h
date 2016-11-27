//
//  UIImage+BoomAddition.h
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/26.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BoomAddition)

- (UIImage *)scaleImageToSize:(CGSize)size;

- (UIColor *)pixelColorWithPoint:(CGPoint)point;

@end
