//
//  WIBrushView.h
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/3.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WIBrushView : UIImageView

- (void)cleanBrushView;

- (void)handleTouchBegan:(UITouch *)touch;

- (void)handleTouchMoved:(UITouch *)touch;

- (void)handleTouchEnded:(UITouch *)touch;

@end
