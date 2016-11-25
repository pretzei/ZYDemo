//
//  ViewController.m
//  ZYDemo
//
//  Created by wilab-pretzei on 16/10/10.
//  Copyright © 2016年 wilab-pretzei. All rights reserved.
//

#import "ViewController.h"
#import "WIGLPaintView.h"
#import "UIView+GLAddition.h"
#import "WIBackView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *centerImage;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WIBackView *backView = [[WIBackView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view insertSubview:backView belowSubview:_btn];
    WIGLPaintView *glView = [[WIGLPaintView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    glView.backgroundImage = [self.view snapshotImage];
    [backView addSubview:glView];
    backView.glView = glView;
    glView.hidden = YES;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)touch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
