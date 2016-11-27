//
//  WIBackView.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/10/19.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "WIBackView.h"
#import "WIGLPaintView.h"

@interface WIBackView ()

@property (nonatomic) UITouch *acTouch;

@end

@implementation WIBackView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _glView.hidden = NO;
    _glView.alpha = 1;
    for (UITouch *touch in touches) {
        if (self.acTouch) {
            [_glView handleTouchEnd:self.acTouch];
            self.acTouch = nil;
        }
        self.acTouch = touch;
        [_glView handleTouchBegan:touch];
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (self.acTouch == touch) {
            [_glView handleTouchMove:touch];
        }
        
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (self.acTouch == touch) {
            [_glView handleTouchEnd:touch];
            self.acTouch = nil;
        }
        
    }
    [UIView animateWithDuration:0.5 animations:^{
        _glView.alpha = 0;
    }completion:^(BOOL finish) {
        _glView.hidden = YES;
        [_glView clearRenderView];
    }];
}

@end
