//
//  RootViewController.m
//  二维码
//
//  Created by Lemon on 16/8/11.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "RootViewController.h"
@interface RootViewController ()

@end

@implementation RootViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self.navigationController.navigationBar.subviews objectAtIndex:0] setAlpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor orangeColor]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}







@end
