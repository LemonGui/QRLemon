//
//  QRUtility.m
//  二维码
//
//  Created by Lemon on 16/8/12.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import "QRUtility.h"
#import "UIImage+SYGenerateQrCode.h"
@implementation QRUtility

+(UIImage *)ceratQRImageWithLink:(NSString *)link style:(NSInteger)style{
    UIImage * image = nil;
    style = style % 10;
    switch (style) {
        case 0:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0];
            break;
        case 1:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 RGB:@"#ee68ba"];
            break;
        case 2:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 insertImage:[UIImage imageNamed:@"IMG_0077"] radius:10];
            break;
        case 3:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 RGB:@"#ee68ba" insertImage:[UIImage imageNamed:@"IMG_0077"] radius:10];
            break;
        case 4:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 backgroundImage:[UIImage imageNamed:@"backImage"]];
            break;
        case 5:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 RGB:@"#ee68ba" backgroundImage:[UIImage imageNamed:@"backImage"] insertImage:[UIImage imageNamed:@"IMG_0077"] radius:10];
            break;
        case 6:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 fillImage:[UIImage imageNamed:@"形状111"]];
            break;
        case 7:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 fillImage:[UIImage imageNamed:@"形状222"] color1:@"#1dacea" color2:@"#2d9f7c"];
            break;
        case 8:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 fillImage:[UIImage imageNamed:@"形状111"] color1:nil color2:nil backgroundImage:[UIImage imageNamed:@"backImage"]];
            break;
        case 9:
            image = [UIImage generateImageWithQrCode:link QrCodeImageSize:0 fillImage:[UIImage imageNamed:@"形状222"] color1:@"#d40606" color2:@"#a10acc" backgroundImage:[UIImage imageNamed:@"backImage"] insertImage:[UIImage imageNamed:@"IMG_0077"] radius:10];
            break;
    }
    return image;
}


@end
