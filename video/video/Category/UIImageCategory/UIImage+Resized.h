//
//  UIImage+Resized.h
//  HMV
//
//  Created by 孙旭让 on 15/6/28.
//  Copyright (c) 2015年 AID Partners Capital Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resized)

+ (UIImage *)resizedImageWithName:(NSString *)name;

+ (UIImage *)resizedImageWithName:(NSString *)name
                             left:(CGFloat)left
                              top:(CGFloat)top;

+ (UIImage *)imageWithOriginalName:(NSString *)imageName;

// 改变UIImage的尺寸
- (UIImage *)resizedWithWidth:(CGFloat)width
                       height:(CGFloat)height;

+ (UIImage*)imageWithImage:(UIImage*)sourceImage
              scaledToSize:(CGSize)newSize;
@end
