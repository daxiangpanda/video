//
//  UIImage+PointColor.m
//  video
//
//  Created by 刘鑫忠 on 2018/7/25.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import "UIImage+PointColor.h"
//#import <opencv2/opencv.hpp>

@implementation UIImage (PointColor)

//- (IplImage *)CreateIplImage{
//    CGImageRef imageRef = self.CGImage;
//
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    IplImage *iplimage = cvCreateImage(cvSize(self.size.width, self.size.height), IPL_DEPTH_8U, 4);
//    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
//                                                    iplimage->depth, iplimage->widthStep,
//                                                    colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
//    CGContextDrawImage(contextRef, CGRectMake(0, 0, self.size.width, self.size.height), imageRef);
//    CGContextRelease(contextRef);
//    CGColorSpaceRelease(colorSpace);
//
//    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
//    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
//    cvReleaseImage(&iplimage);
//
//    return ret;
//}

- (UIColor *)colorAtPixel:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }

    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |     kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)averageColor {
    NSMutableArray <UIColor *> *colorArray = [NSMutableArray array];
    CGFloat sumRed = 0.0f;
    CGFloat threshold = 30.0f;
    for(int w = 0;w<self.size.width;w++){
        for(int h = 0;h<self.size.height;h++){
            UIColor *pointColor = [self colorAtPixel:CGPointMake(w, h)];
            NSMutableArray *colorArray = [self changeUIColorToRGB:pointColor];
            sumRed+= [colorArray.firstObject intValue];
        }
    }
    
    CGFloat aveRed = sumRed / self.size.width / self.size.height;
    
    for(int w = 0;w<self.size.width;w++){
        for(int h = 0;h<self.size.height;h++){
            UIColor *pointColor = [self colorAtPixel:CGPointMake(w, h)];
            NSMutableArray *colorS = [self changeUIColorToRGB:pointColor];
            if(ABS([colorS.firstObject intValue] - aveRed) > threshold) {
                [colorArray addObject:pointColor];
            }
        }
    }
    
    if(colorArray.count == 0) {
        return UIColor.blackColor;
    }
    
    float sum_r = 0.0;
    float sum_g = 0.0;
    float sum_b = 0.0;
    for (UIColor *color in colorArray){
        CGFloat redComponenet = [[self changeUIColorToRGB:color][0] intValue];
        CGFloat greenComponenet = [[self changeUIColorToRGB:color][1] intValue];
        CGFloat blueComponenet = [[self changeUIColorToRGB:color][2] intValue];
        sum_r+=redComponenet;
        sum_g+=greenComponenet;
        sum_b+=blueComponenet;
    }
    return [UIColor colorWithRed:sum_r / colorArray.count / 255.0 green:sum_g / colorArray.count / 255.0 blue:sum_b / colorArray.count / 255.0 alpha:1.0];
}

- (NSMutableArray *) changeUIColorToRGB:(UIColor *)color {
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值
    int r = [[RGBArr objectAtIndex:1] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",r];
    [RGBStrValueArr addObject:RGBStr];
    //获取绿色值
    int g = [[RGBArr objectAtIndex:2] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",g];
    [RGBStrValueArr addObject:RGBStr];
    //获取蓝色值
    int b = [[RGBArr objectAtIndex:3] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%d",b];
    [RGBStrValueArr addObject:RGBStr];
    //返回保存RGB值的数组
    return RGBStrValueArr;
}
@end
