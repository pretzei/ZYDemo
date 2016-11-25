//
//  WIGLPaintView.h
//  ZYDemo
//
//  Created by wilab-pretzei on 16/10/10.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface WIGLPaintView : UIView

@property (nonatomic, retain) UIImage *backgroundImage;

- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;

- (void)clearRenderView;    //清空画面

- (void)handleTouchBegan:(UITouch *)touch;

- (void)handleTouchMove:(UITouch *)touch;

- (void)handleTouchEnd:(UITouch *)touch;

@end
