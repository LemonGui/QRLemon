//
//  QRUtility.h
//  二维码
//
//  Created by Lemon on 16/8/12.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRUtility : NSObject

+(UIImage *)ceratQRImageWithLink:(NSString *)link style:(NSInteger)style;

@end
