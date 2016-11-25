//
//  UIView+GLAddition.h
//  ZYDemo
//
//  Created by wilab-pretzei on 16/10/19.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GLAddition)

/**
 Create a snapshot image of the complete view hierarchy.
 */
- (nullable UIImage *)snapshotImage;

- (nullable UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

@end
