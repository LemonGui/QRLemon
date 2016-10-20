//
//  MyQRViewController.m
//  二维码
//
//  Created by Lemon on 16/8/10.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "MyQRViewController.h"
#import "UIImage+SYGenerateQrCode.h"
#import "QRUtility.h"

#define QRLINK @"http://www.jianshu.com/users/3ab8aeac97e4/latest_articles"
@interface MyQRViewController ()
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIImageView *myQRImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation MyQRViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpNavigation];
    
    self.myQRImageView.image = [QRUtility ceratQRImageWithLink:QRLINK style:arc4random()%10];
    _baseView.layer.borderColor = [UIColor grayColor].CGColor;
    _baseView.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    _baseView.layer.cornerRadius = 3;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qrClick)];
    [_baseView addGestureRecognizer:tap];
    
    _iconImageView.layer.cornerRadius = _iconImageView.width/2;
    
}

-(void)qrClick{
    static NSInteger style;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"换个样式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.myQRImageView.image = [QRUtility ceratQRImageWithLink:QRLINK style:style++];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"保存到手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIImageWriteToSavedPhotosAlbum([UIImage convertViewToImage:_baseView], nil, nil, nil);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"保存成功";
        [hud hideAnimated:YES afterDelay:1];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)setUpNavigation{
    self.title = @"我的二维码";
}

@end
