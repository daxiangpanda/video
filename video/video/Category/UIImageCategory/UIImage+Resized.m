//
//  UIImage+Resized.m
//  HMV
//
//  Created by 孙旭让 on 15/6/28.
//  Copyright (c) 2015年 AID Partners Capital Limited. All rights reserved.
//

#import "UIImage+Resized.h"

@implementation UIImage (Resized)

+ (UIImage *)resizedImageWithName:(NSString *)name
{
    return [self resizedImageWithName:name
                                 left:0.5
                                  top:0.5];
}

+ (UIImage *)resizedImageWithName:(NSString *)name
                             left:(CGFloat)left
                              top:(CGFloat)top
{
    UIImage *image = [UIImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * left
                                      topCapHeight:image.size.height * top];
}

+ (UIImage *)imageWithOriginalName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
