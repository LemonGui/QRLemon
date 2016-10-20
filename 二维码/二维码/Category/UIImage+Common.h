//
//  UIImage+Common.h
//  Created by Lemon on 16/8/11.
//  Copyright © 2016年 Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Common)
/**
 *  改变图片颜色
 */
- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
/**
 *  改变图片颜色（带渐变色）
 */
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;

//加载不渲染的图片
+(instancetype)imageWithOriginalName:(NSString *)imageName;

/**
 *  中心扩展拉伸图片
 */
+(instancetype)imageResizingWithName:(NSString * )imageName;
/**
 *  根据颜色生成图片
 */
+ (instancetype)imageWithColor:(UIColor *)color;

/**
 *  设置图片size
 */
+ (instancetype)image:(UIImage*)image byScalingToSize:(CGSize)targetSize;

/**
 *
 设置圆形image
 */
- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius;

/**
 *  生成二维码图片
 *  @param string link 连接
 *  @param size   生成图片大小
 *  @return image
 */
+ (UIImage *)createQRCodeFromLink:(NSString *)link;

/**
 *  将view转换成image
 */
+ (UIImage*)convertViewToImage:(UIView*)view;


@end
