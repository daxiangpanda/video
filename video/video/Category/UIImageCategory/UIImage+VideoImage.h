//
//  UIImage+VideoImage.h
//  vtell
//
//  Created by sohu on 2017/6/22.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VideoImage)

+ (UIImage *_Nullable) thumbnailImageForVideo:(NSURL *_Nonnull)videoURL atTime:(NSTimeInterval)time;

@end
