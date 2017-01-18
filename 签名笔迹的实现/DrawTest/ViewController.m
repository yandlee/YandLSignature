//
//  ViewController.m
//  DrawTest
//
//  Created by YandL on 16/7/6.
//  Copyright © 2016年 YandL. All rights reserved.
//

#import "ViewController.h"
#import "TXBYDrawView.h"

@interface ViewController ()
/**
 *  drawView
 */
@property (nonatomic, strong) TXBYDrawView *drawView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createDrawView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)createDrawView {
    self.drawView = [[TXBYDrawView alloc] init];
    self.drawView.frame = [UIScreen mainScreen].bounds;
    self.drawView.backgroundColor = [UIColor whiteColor];
    self.drawView.breakTime = 100;
    [self.view addSubview:self.drawView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.borderWidth = 1.5;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn.layer.cornerRadius = 7;
    btn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 / 2 - 50, [UIScreen mainScreen].bounds.size.height - 80, 120, 45);
    [btn setTitle:@"Show" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.backgroundColor = [UIColor whiteColor];
    btn1.layer.borderWidth = 1.5;
    btn1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn1.layer.cornerRadius = 7;
    btn1.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 4 * 3 - 70, [UIScreen mainScreen].bounds.size.height - 80, 120, 45);
    [btn1 setTitle:@"Clean" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
    btn1.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    [self.view addSubview:btn1];
}

- (void)btnClick {
    [self.drawView showHistory];
}

- (void)btn1Click {
    self.drawView = nil;
    [self createDrawView];
}

@end
