//
//  WIPulseLayerViewController.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/25.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "WIPulseLayerViewController.h"
#import "WIPulseLayer.h"

@interface WIPulseLayerViewController ()

@end

@implementation WIPulseLayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [WIPulseLayer pulseInView:self.view point:[touches.anyObject locationInView:self.view] color:[UIColor redColor] size:50];
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
