//
//  MattingController.m
//  video
//
//  Created by 刘鑫忠 on 2018/7/26.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import "MattingController.h"
#import "UIImage+resized.h"
#import "UIImage+PixelBuffer.h"
#import "HEDso_1.h"

#import <CoreML/CoreML.h>
//#import "HEDso.h"

@interface MattingController ()

@property (nonatomic, strong) HEDso_1 *model;

@property (nonatomic, strong) UIImage *inputImage;

@end

@implementation MattingController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *fImage = [UIImage imageNamed:@"pic1.jpg"];
    _inputImage = [fImage resizedWithWidth:500 height:500];
    UIImageWriteToSavedPhotosAlbum(_inputImage, nil, nil, nil);
    CVPixelBufferRef buffer = [_inputImage pixelBufferWithWidth:500 height:500];

    HEDso_1Output *outPut = [self.model predictionFromData:buffer error:nil];
    
    NSLog(@"%@",outPut);
    
    
    Byte res[250000];
    for(int i = 0;i<500;i++){
        for(int j = 0;j<500;j++){
//            NSInteger index = i * 500 +j;
////            dataPointer[0];
//            double value = [[outPut.upscore_dsn3 objectAtIndexedSubscript:index] doubleValue];
////            double value = [outPut.upscore_dsn3[index] doubleValue];
//            double result = [self sigmoid:value];
//            //            printf(result * 255);
//            //            outPut.upscore_dsn3[index] = [NSNumber numberWithFloat:result * 255];
//
//            res[index] = (int)(result * 255);
//
////            [outPut.upscore_dsn3 setObject:[NSNumber numberWithUnsignedInteger:(result * 255)] atIndexedSubscript:index];
//
////            outPut.upscore_dsn3[index] = [NSNumber numberWithDouble:(result * 255)];
//
//            if(result > 0.1) {
//                //                NSLog(@"%d",(UInt8)(result) * 255);
//            }
////            gray[index] = (UInt8)(result) * 255;
//            //            gray[index] = (UInt8)([self sigmoid:[outPut.upscore_dsn3[index] doubleValue]] * 255);
            
            
            
            NSInteger index = i * 500 +j;
            //            dataPointer[0];
            double value = [[outPut.upscore_dsn2 objectAtIndexedSubscript:index] doubleValue];
            //            double value = [outPut.upscore_dsn3[index] doubleValue];
            double result = [self sigmoid:value];
            //            printf(result * 255);
            //            outPut.upscore_dsn3[index] = [NSNumber numberWithFloat:result * 255];
            
            res[index] = (int)(result * 255);
            
            //            [outPut.upscore_dsn3 setObject:[NSNumber numberWithUnsignedInteger:(result * 255)] atIndexedSubscript:index];
            
            //            outPut.upscore_dsn3[index] = [NSNumber numberWithDouble:(result * 255)];
            
            if(result > 0.1) {
                //                NSLog(@"%d",(UInt8)(result) * 255);
            }
            //            gray[index] = (UInt8)(result) * 255;
            //            gray[index] = (UInt8)([self sigmoid:[outPut.upscore_dsn3[index] doubleValue]] * 255);

        }
    }
    
    NSData *d = [NSData dataWithBytes:res length:250000 ];
    UIImageWriteToSavedPhotosAlbum([self grayScaleImageWithData:d size:CGSizeMake(500, 500)], nil, nil, nil);

//    outPut.upscore_dsn3.dataPointer
//    NSString *resultString = @"";
//    for(int i = 0;i<outPut.upscore_dsn3.count;i++){
//        CGFloat percent = [self sigmoid:[outPut.upscore_dsn3[i] floatValue]];
//        if(percent > 0.1) {
////            NSLog(@"output[%d]:%f",i,percent);
//        }
//
//        NSString *iStr = [NSString stringWithFormat:@"%f\n",percent];
//        resultString = [resultString stringByAppendingString:iStr];
//    }
//
//    UInt8 gray[500 * 500];
//    NSMutableData *data = [NSMutableData dataWithLength:500 * 500];
//    for(int i = 0;i<500;i++){
//        for(int j = 0;j<500;j++){
//            NSInteger index = i * 500 +j;
//            double value = [outPut.upscore_dsn3[index] doubleValue];
//            double result = [self sigmoid:value];
////            printf(result * 255);
//            if(result > 0.1){
////                NSLog(@"%d",(UInt8)(result) * 255);
//            }
//            gray[index] = (UInt8)(result) * 255;
////            gray[index] = (UInt8)([self sigmoid:[outPut.upscore_dsn3[index] doubleValue]] * 255);
//        }
//    }
//    for(int i = 0;i<outPut.upscore_dsn3.count;i++){
////        NSLog(@"%d",(UInt8)([self sigmoid:[outPut.upscore_fuse[i] floatValue]] * 255));
//
//    }
    
    

    

    CFDataRef cfData = CFDataCreate(nil,res, 500 * 500);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(cfData);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGImageRef cgImage = CGImageCreate(500, 500, 8, 8, 500, colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider,nil, YES, kCGRenderingIntentDefault);
    
    
//    (500, 500, 8, 8, 500, colorSpace, nil, provider, nil, YES, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//    [UIImage imageWithCGImage:cgImage];
    
}


- (double)sigmoid:(double)input {
    return 1 / (1 + exp(-input));
}
- (HEDso_1 *)model {
    if(!_model) {
        _model = [[HEDso_1 alloc]init];
    }
    return _model;
}


//- (HEDfuse_1 *)modelFuse {
//    if(!_modelFuse) {
//        _modelFuse = [[HEDfuse_1 alloc]init];
//    }
//    return _modelFuse;
//}

- (UIImage *)grayScaleImageWithData:(NSData *)grayScaleData
                               size:(CGSize)imageSize {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    Byte *rawData = (Byte *)grayScaleData.bytes;
    CGContextRef context = CGBitmapContextCreate(rawData, imageSize.width, imageSize.height, 8, imageSize.width * sizeof(Byte), colorSpace, kCGImageAlphaNone);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:imageRef];
    CFRelease(context);
    CFRelease(colorSpace);
    CFRelease(imageRef);
    return grayImage;
    
}
@end
