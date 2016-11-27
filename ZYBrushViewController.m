//
//  ZYBrushViewController.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/11/3.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "ZYBrushViewController.h"
#import "WIBrushView.h"

@interface ZYBrushViewController ()

@end

@implementation ZYBrushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WIBrushView *brushView = [[WIBrushView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:brushView];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
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
