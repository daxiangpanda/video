//
//  UIImage+PixelBuffer.h
//  video
//
//  Created by 刘鑫忠 on 2018/7/26.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (PixelBuffer)

- (CVPixelBufferRef)pixelBufferWithWidth:(CGFloat)width height:(CGFloat)height ;

@end

NS_ASSUME_NONNULL_END
