//
//  UIImage+PixelBuffer.m
//  video
//
//  Created by 刘鑫忠 on 2018/7/26.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import "UIImage+PixelBuffer.h"

@implementation UIImage (PixelBuffer)

- (CVPixelBufferRef)pixelBufferWithWidth:(CGFloat)width height:(CGFloat)height {
    CVPixelBufferRef maybePixelBufferRef = NULL;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                          height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &maybePixelBufferRef);
    
    if(status != kCVReturnSuccess){
        return nil;
    }
    CVPixelBufferRef pixelBuffer = maybePixelBufferRef;
    void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    CGContextRef context = CGBitmapContextCreate(pixelData, width, height, 8, CVPixelBufferGetBytesPerRow(pixelBuffer), CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipFirst);
    
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    UIGraphicsPushContext(context);
    [self drawInRect:CGRectMake(0, 0, width, height)];
    UIGraphicsPopContext();
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}

@end
