//
//  WIBoomLayer.h
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/27.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WIBoomLayer : CALayer

- (instancetype)initWithPoint:(CGPoint)point size:(CGFloat)size color:(UIColor *)color perSize:(CGFloat)pSize;

- (void)explode;

@end
