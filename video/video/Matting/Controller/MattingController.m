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
#import "HEDso3_1.h"
#import <CoreML/CoreML.h>
//#import "HEDso.h"

@interface MattingController ()

@property (nonatomic, strong) HEDso3_1 *model;
@property (nonatomic, strong) UIImage *inputImage;

@end

@implementation MattingController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *fImage = [UIImage imageNamed:@"pic1.jpg"];
    _inputImage = [fImage resizedWithWidth:500 height:500];
    UIImageWriteToSavedPhotosAlbum(_inputImage, nil, nil, nil);
    CVPixelBufferRef buffer = [_inputImage pixelBufferWithWidth:500 height:500];
    HEDso3_1Output *outPut = [self.model predictionFromData:buffer error:nil];
    NSLog(@"%@",outPut);
    for(int i = 0;i<outPut.upscore_dsn3.count;i++){
        CGFloat percent = [self sigmoid:[outPut.upscore_dsn3[i] floatValue]];
        if(percent > 0.01) {
            NSLog(@"output[%d]:%f",i,percent);
        }
    }
    
    UInt8 gray[500 * 500];
    NSMutableData *data = [NSMutableData dataWithLength:500 * 500];
//    [data bytes][0];
    Byte byte[500 * 500];
    for(int i = 0;i<500;i++){
        for(int j = 0;j<500;j++){
            NSInteger index = i * 500 +j;
            CGFloat value = [outPut.upscore_dsn3[index] doubleValue];
            CGFloat result = [self sigmoid:value];
            gray[index] = (UInt8)(result * 255);
//            gray[index] = (UInt8)([self sigmoid:[outPut.upscore_dsn3[index] doubleValue]] * 255);
        }
    }
    for(int i = 0;i<outPut.upscore_dsn3.count;i++){
//        NSLog(@"%d",(UInt8)([self sigmoid:[outPut.upscore_fuse[i] floatValue]] * 255));
        
    }
    NSData *imageData = [NSData dataWithBytes:gray length:500 * 500];
//    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
//    [UIImage imageWithData:imageData];
    CFDataRef cfData = CFDataCreate(nil, gray, 500 * 500);
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(cfData);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGImageRef cgImage = CGImageCreate(500, 500, 8, 8, 500, colorSpace, nil, provider, nil, YES, kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//    [UIImage imageWithCGImage:cgImage];
    
}


- (CGFloat)sigmoid:(CGFloat)input {
    return 1 / (1 + exp(-input));
}
- (HEDso3_1 *)model {
    if(!_model) {
        _model = [[HEDso3_1 alloc]init];
    }
    return _model;
}

@end
