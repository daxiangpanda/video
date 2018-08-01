//
//  MultiplyFilterController.m
//  video
//
//  Created by 刘鑫忠 on 2018/8/1.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//

#import "MultiplyFilterController.h"
#import "UIImage+resized.h"
#import <GPUImage.h>

@interface MultiplyFilterController ()

@property (nonatomic, strong) UIImageView       *bgImageView;
@property (nonatomic, strong) UIButton          *blendButton;
@property (nonatomic, strong) UIButton          *blendButtonGPUImage;

@property (nonatomic, strong) UIImage           *layerImage;

@end

@implementation MultiplyFilterController


- (instancetype)init {
    self = [super init];
    if(self){
        [self setupView];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupView {
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.blendButton];
    [self.view addSubview:self.blendButtonGPUImage];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"flower" ofType:@"png" inDirectory:@"flower"];
    self.bgImageView.image = [UIImage imageWithContentsOfFile:path];
}

- (void)blendButtonTapped {
    [self blendBgWithLayer];
}

- (void)blendButtonGPUImageTapped {
    [self blendBgWithLayerUsingGPUImage];
}

- (void)blendBgWithLayer {
    UIImage *bgImage = self.bgImageView.image;
    CGSize bgImageSize = bgImage.size;
    UIImage *resizedLayerImage = [UIImage imageWithImage:self.layerImage scaledToSize:bgImageSize];
    CIImage *cibgImage = [CIImage imageWithCGImage:bgImage.CGImage];
    CIImage *cilayerImage = [CIImage imageWithCGImage:resizedLayerImage.CGImage];
    
    CIFilter *cifilter = [CIFilter filterWithName:@"CIMultiplyBlendMode"];
    
    [cifilter setValue:cilayerImage forKey:@"inputImage"];
    [cifilter setValue:cibgImage forKey:@"inputBackgroundImage"];
    
    //获取 image的 CGContextRef
    CGContextRef cgContext = UIGraphicsGetCurrentContext();
    
    //CGContextRef 和 CIContext 关联(二者表示同一画布)
    CIContext *context = [CIContext contextWithCGContext:cgContext options:nil];
    NSLog(@"1");
    UIImage *outputImage = [self imageFromCIImage:[cifilter outputImage] content:context];
    NSLog(@"2");
    self.bgImageView.image = outputImage;
}

- (void)blendBgWithLayerUsingGPUImage {
    UIImage *bgImage = self.bgImageView.image;
    CGSize bgImageSize = bgImage.size;
    UIImage *resizedLayerImage = [UIImage imageWithImage:self.layerImage scaledToSize:bgImageSize];
    
    NSLog(@"1");
    GPUImageMultiplyBlendFilter *blendFilter = [[GPUImageMultiplyBlendFilter alloc] init];
    GPUImagePicture *imageToProcess = [[GPUImagePicture alloc] initWithImage:bgImage];
    GPUImagePicture *border = [[GPUImagePicture alloc] initWithImage:resizedLayerImage];
    
//    blendFilter.mix = 1.0f;
    [blendFilter useNextFrameForImageCapture];
    [imageToProcess addTarget:blendFilter];
    [border addTarget:blendFilter];
    
    [imageToProcess processImage];
    [border processImage];
    NSLog(@"2");
    self.bgImageView.image = [blendFilter imageFromCurrentFramebuffer];

    
//    self.bgImageView.image = [blendFilter imageFromCurrentFramebuffer];
//    CIImage *cibgImage = [CIImage imageWithCGImage:bgImage.CGImage];
//    CIImage *cilayerImage = [CIImage imageWithCGImage:resizedLayerImage.CGImage];
//
//    CIFilter *cifilter = [CIFilter filterWithName:@"CIMultiplyBlendMode"];
//
//    [cifilter setValue:cilayerImage forKey:@"inputImage"];
//    [cifilter setValue:cibgImage forKey:@"inputBackgroundImage"];
//
//    //获取 image的 CGContextRef
//    CGContextRef cgContext = UIGraphicsGetCurrentContext();
//
//    //CGContextRef 和 CIContext 关联(二者表示同一画布)
//    CIContext *context = [CIContext contextWithCGContext:cgContext options:nil];
//    NSLog(@"1");
//    UIImage *outputImage = [self imageFromCIImage:[cifilter outputImage] content:context];
//    NSLog(@"2");
//    self.bgImageView.image = outputImage;
}

- (UIImage *)imageFromCIImage:(CIImage *)ciImage content:(CIContext *)content{
    UIImage *image = nil;
    if(content) {
        CGImageRef imageRef = [content createCGImage:ciImage fromRect:[ciImage extent]];
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }else {
        image = [UIImage imageWithCIImage:ciImage];
    }
    return image;
}

- (UIImageView *)bgImageView {
    if(!_bgImageView) {
        _bgImageView = [[UIImageView alloc]init];
        _bgImageView.frame = self.view.frame;
    }
    return _bgImageView;
}

- (UIButton *)blendButton {
    if(!_blendButton) {
        _blendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _blendButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, 100, 100);
        [_blendButton addTarget:self action:@selector(blendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        _blendButton.backgroundColor = [UIColor clearColor];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_blendButton addSubview:titleLabel];
        titleLabel.text = @"切换背景";
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.textColor = [UIColor blackColor];
    }
    return _blendButton;
}

- (UIButton *)blendButtonGPUImage {
    if(!_blendButtonGPUImage) {
        _blendButtonGPUImage = [UIButton buttonWithType:UIButtonTypeCustom];
        _blendButtonGPUImage.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 100, [UIScreen mainScreen].bounds.size.height - 100, 100, 100);
        [_blendButtonGPUImage addTarget:self action:@selector(blendButtonGPUImageTapped) forControlEvents:UIControlEventTouchUpInside];
        _blendButtonGPUImage.backgroundColor = [UIColor clearColor];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_blendButtonGPUImage addSubview:titleLabel];
        titleLabel.text = @"切换背景GPUImage";
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.textColor = [UIColor blackColor];
    }
    return _blendButtonGPUImage;
}

- (UIImage *)layerImage {
    if(!_layerImage) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"WID-big" ofType:@"png" inDirectory:@"flower"];
        _layerImage = [UIImage imageWithContentsOfFile:path];
    }
    return _layerImage;
}
@end
