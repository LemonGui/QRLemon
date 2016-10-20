//
//  QRCreatViewController.m
//  二维码
//
//  Created by Lemon on 16/8/11.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "QRCreatViewController.h"
#import "UIImage+SYGenerateQrCode.h"
#import "QRUtility.h"
#import "UIImage+Common.h"

#define QRLINK @"http://www.jianshu.com/users/3ab8aeac97e4/latest_articles"
@interface QRCreatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *qrTextView;
@property (weak, nonatomic) IBOutlet UIImageView *outPutImage;
@property (assign, nonatomic) NSInteger count;

@end

@implementation QRCreatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"制作二维码";
    /**普通默认黑色 */
    self.outPutImage.image = [UIImage createQRCodeFromLink:QRLINK];//[UIImage generateImageWithQrCode:QRLINK QrCodeImageSize:0];
    _outPutImage.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(analyzeImage:)];
    [_outPutImage addGestureRecognizer:longPress];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveImage)];
    [_outPutImage addGestureRecognizer:tap];
}

-(void)saveImage{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否保存图片" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(_outPutImage.image, nil, nil, nil);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"保存成功";
        [hud hideAnimated:YES afterDelay:1];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)creatQR:(id)sender {
    
    [self.qrTextView endEditing:YES];
    NSString * link = self.qrTextView.text.length > 0 ? self.qrTextView.text : QRLINK;
    self.outPutImage.image = [QRUtility ceratQRImageWithLink:link style:_count];
}

- (IBAction)changeStyle:(id)sender {
    _count++;
    [self creatQR:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.qrTextView endEditing:YES];
}

-(void)analyzeImage:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
    [self decodeImage:_outPutImage.image];
}

#pragma mark - 识别图片中的二维码信息
-(void)decodeImage:(UIImage*)image{
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
    }
}


@end
