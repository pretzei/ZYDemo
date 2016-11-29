//
//  ZYBoomViewController.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/27.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "ZYBoomViewController.h"
#import "UIView+BoomAddition.h"

@interface ZYBoomViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ZYBoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)buttonTouch:(id)sender {
    [_imageView explodeWithSize:100 point:CGPointMake(_imageView.frame.size.width / 2, _imageView.frame.size.height / 2)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
