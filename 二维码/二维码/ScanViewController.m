//
//  ScanViewController.m
//  二维码
//
//  Created by Lemon on 16/8/10.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MyQRViewController.h"

//#import "ZXingObjC.h"
static const CGFloat kBorderW = 100;
static const CGFloat kMargin = 30;
static const int kScal = 4;
#define LightBule [UIColor colorWithRed:0.06f green:0.76f blue:1.00f alpha:1.00f]
#define scanWindowHW  (self.view.width - kMargin * kScal)

@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak)   UIView *maskView;
@property (nonatomic, strong) UIImageView *scanWindow;
@property (nonatomic, strong) UIImageView *scanNetImageView;

@end

@implementation ScanViewController

#pragma mark - 生命周期
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_session.running) {
        [self resumeAnimation];
    }
    
    [[self.navigationController.navigationBar.subviews objectAtIndex:0] setAlpha:0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    //1.遮盖
    [self setMaskView];
    //2.导航条
    [self setUpNavigation];
    //3.扫描区域
    [self setupScanWindowView];
    //4.扫描
    [self startRunning];
    //5.进入Foreground通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterForegroundHandler) name:@"EnterForeground" object:nil];

}

#pragma mark - 扫描初始化
-(void)startRunning{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"准备中...";
    hud.centerY = _scanWindow.centerY;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.contentColor = [UIColor whiteColor];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self beginScanning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self resumeAnimation];
        });
    });

}


-(void)setMaskView{
    CGFloat margin = kMargin * kScal * 0.5;
    [self creatViewWithFrame:CGRectMake(0, 0, self.view.width, kBorderW)];
    [self creatViewWithFrame:CGRectMake(0, kBorderW, kMargin * kScal * 0.5, scanWindowHW)];
    [self creatViewWithFrame:CGRectMake(self.view.width - margin, kBorderW, margin , scanWindowHW)];
    [self creatViewWithFrame:CGRectMake(0, kBorderW + scanWindowHW, self.view.width, self.view.height - kBorderW - scanWindowHW)];
}

-(void)creatViewWithFrame:(CGRect)rect{
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:view];
}

- (void)setupScanWindowView
{
    _scanWindow = [[UIImageView alloc] initWithFrame:CGRectMake(kMargin * kScal * 0.5, kBorderW, scanWindowHW, scanWindowHW)];
    _scanWindow.image = [[UIImage imageNamed:@"扫描框"] imageWithTintColor:LightBule];
    _scanWindow.clipsToBounds = YES;
    [self.view addSubview:_scanWindow];
    
     _scanNetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_scan_light_green"]];
    [_scanWindow addSubview:_scanNetImageView];
     _scanNetImageView.hidden = YES;
    
    //操作提示
    UILabel * tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"将二维码/条码放入框内，即可自动扫描";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.numberOfLines = 2;
    tipLabel.font=[UIFont systemFontOfSize:14];
    tipLabel.backgroundColor = [UIColor clearColor];
    [tipLabel sizeToFit];
    tipLabel.y = CGRectGetMaxY(_scanWindow.frame)+10;
    tipLabel.centerX = self.view.width*0.5;
    [self.view addSubview:tipLabel];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:LightBule forState:UIControlStateNormal];
    [btn setTitle:@"我的二维码" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    btn.y = CGRectGetMaxY(tipLabel.frame)+10;
    [btn sizeToFit];
    btn.centerX = tipLabel.centerX;
    [btn addTarget:self action:@selector(myQRBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

}


-(void)setUpNavigation{
    
    self.title = @"扫一扫";

    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(myAlbum)];
}

-(void)beginScanning{
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
     NSError * error;
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return ;
    }
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
    //设置代理在主线程
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置有效扫描区域
    CGRect scanCrop = [self getScanCrop:_scanWindow.frame readerViewBounds:self.view.frame];
    output.rectOfInterest = scanCrop;
    //初始化连接对象
    _session = [[AVCaptureSession alloc] init];
    //高质量采集率
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    [_session addInput:input];
    [_session addOutput:output];
    
    //设置扫码支持的编码格式-条形码、二维码兼容
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    //开始捕获
    [_session startRunning];
}

-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = rect.origin.y/CGRectGetHeight(readerViewBounds);
    y = rect.origin.x/CGRectGetWidth(readerViewBounds);
    width = CGRectGetHeight(rect)/CGRectGetHeight(readerViewBounds);
    height = CGRectGetWidth(rect)/CGRectGetWidth(readerViewBounds);
    
    return CGRectMake(x, y, width, height);
}

#pragma mark - action

-(void)disMiss{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)myAlbum{

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        //1.初始化相册拾取器
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        //2.设置代理
        controller.delegate = self;
        //3.设置资源：
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:controller animated:YES completion:NULL];
        
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(void)myQRBtnClick{
    MyQRViewController * vc = [[MyQRViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterForegroundHandler{
    [_session startRunning];
    [self resumeAnimation];
}


/*
#pragma mark - 开关闪光灯
- (void)turnTorchOn:(BOOL)on
{
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}
*/

#pragma mark 恢复动画
- (void)resumeAnimation
{
    CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
    scanNetAnimation.keyPath = @"transform.translation.y";
    scanNetAnimation.byValue = @(scanWindowHW);
    scanNetAnimation.duration = 2.5;
    scanNetAnimation.repeatCount = MAXFLOAT;
    [_scanNetImageView.layer addAnimation:scanNetAnimation forKey:@"translationAnimation"];
    _scanNetImageView.hidden = NO;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        NSString * scannedResult = metadataObject.stringValue;
        if ([scannedResult hasPrefix:@"http"]) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scannedResult]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scannedResult]];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描结果" message:metadataObject.stringValue delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"再次扫描", nil];
            [alert show];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self disMiss];
    } else if (buttonIndex == 1) {
        [_session startRunning];
    }
}


#pragma mark- imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *pickImage =[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [self decodeImage:pickImage];
        
    }];
    
    
}

#pragma mark - 识别图片中的二维码信息
-(void)decodeImage:(UIImage*)image{
    /**这里你完全可以向下兼容没必要用ios8以上的api但是这里这么写主要是为了介绍ios8后提供的这个api，而且性能和识别率要高于第三方 */
    if(iOS8){
        /**ios8环境以上 */
        //初始化一个监测器
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >=1) {
            /**结果对象 */
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            
            if ([scannedResult hasPrefix:@"http"]) {
                if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:scannedResult]]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scannedResult]];
                }
            }else{
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
        else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
    }else{
        /**ios8环境以下 */
//        
//        CGImageRef imageToDecode = image.CGImage;
//        
//        ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
//        CGImageRelease(imageToDecode);
//        ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
//        
//        NSError *error = nil;
//        
//        ZXDecodeHints *hints = [ZXDecodeHints hints];
//        
//        ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
//        ZXResult *result = [reader decode:bitmap
//                                    hints:hints
//                                    error:&error];
//        if (result) {
//            
//            NSString *contents = result.text;
//            NSLog(@"contents =%@",contents);
//            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"解析成功" message:contents delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            [alter show];
//            
//        } else {
//            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"解析失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            [alter show];
//        }
    }
}


@end
