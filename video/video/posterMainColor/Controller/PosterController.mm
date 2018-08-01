//
//  posterMainColor.m
//  video
//
//  Created by 刘鑫忠 on 2018/7/25.
//  Copyright © 2018 刘鑫忠. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "PosterController.h"
#import "UIImage+PointColor.h"
#import "UIImage+ColorImage.h"
#import "Palette.h"
#import "UIImage+Palette.h"
#import "UIColor+Enhancement.h"
#import "PosterView.h"
#import "TZImagePickerController.h"

#import <objc/runtime.h>
#import "Person.h"

@interface PosterController()<AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView                   *backgroundImageView;
@property (nonatomic, strong) PosterView                    *posterImageView;

@property (nonatomic, assign) BOOL                          useCamera;
@property (nonatomic, strong) AVCaptureSession              *session;
@property (nonatomic, strong) AVCaptureDeviceInput          *videoInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *previewLayer;
@property (nonatomic, strong) AVCaptureDevice               *device;
@property (nonatomic, strong) dispatch_queue_t              bufferQueue;
@property (nonatomic, strong) AVCaptureVideoDataOutput      *dataOutPut;
@property (nonatomic, assign) NSInteger                     currentIndex;

@property (nonatomic, strong) UIButton                      *imagePickerButton;

@property (nonatomic, strong) UILabel                       *testLabel;
@property (nonatomic, strong) NSMutableArray                *array;
@end


@implementation PosterController

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setupData];
        [self setupView];
        [self addGesture];
    }
    return self;
}

- (void)setupView {
    [self.view addSubview:self.backgroundImageView];
    
    [self.view addSubview:self.posterImageView];
    [self.view addSubview:self.imagePickerButton];
    
    UIImage *mainImage = _array[_currentIndex % _array.count];
//    self.backgroundImageView.image  = mainImage;
    [self changeBackgroundImage:mainImage];
//    [self.view addSubview:self.testLabel];

}

- (void)setupData {
    _currentIndex = 0;
    _useCamera = NO;
    self.bufferQueue = dispatch_queue_create("bufferQueue", NULL);
    NSMutableArray *array = [NSMutableArray array];
    for(NSString *path in [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"flower"]) {
        [array addObject:[UIImage imageWithContentsOfFile:path]];
    }
    _array = array;
}

- (void)addGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doTap)];
    self.posterImageView.userInteractionEnabled = YES;
    [self.posterImageView addGestureRecognizer:tap];

}

- (void)doTap {
//    NSArray *array = @[[UIImage imageNamed:@"flower2"],[UIImage imageNamed:@"pic1.jpg"],[UIImage imageNamed:@"tea.jpeg"],[UIImage imageNamed:@"sky.jpg"],[UIImage imageNamed:@"flower"],[UIImage imageNamed:@"indoor.jpg"],[UIImage imageNamed:@"flower1"]];
//    NSLog(@"%@",[[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"flower"]);

    [self changeBackgroundImage:_array[_currentIndex % _array.count]];
}


- (void)changeBackgroundImage:(UIImage *)image {
    self.backgroundImageView.image = image;
    _currentIndex += 1;
    __weak typeof (self) weakSelf = self;
    [self.backgroundImageView.image getPaletteImageColor:^(PaletteColorModel *recommendColor, NSDictionary *allModeColorDic, NSError *error) {
        if (!recommendColor){
            return;
        }
//        CGFloat maxPercentage = 0.0;
//        NSString *maxColor;
//        for (NSString *key in allModeColorDic) {
//            if([allModeColorDic[key] isKindOfClass:[PaletteColorModel class]]) {
////                NSLog(@"____percentage:%f",((PaletteColorModel *)allModeColorDic[key]).percentage);
//                if(((PaletteColorModel *)allModeColorDic[key]).percentage > maxPercentage) {
//                    maxPercentage = ((PaletteColorModel *)allModeColorDic[key]).percentage;
//                    maxColor = ((PaletteColorModel *)allModeColorDic[key]).imageColorString;
//                }
//            }
//            if([allModeColorDic[key] isKindOfClass:[PaletteColorModel class]]) {
////                NSLog(@"key: %@ value: %@", key, ((PaletteColorModel *)allModeColorDic[key]).imageColorString);
//            }
//        }
//        
////        NSLog(@"maxColor:%@,_________percentage:%f",maxColor,maxPercentage);
////        NSLog(@"recommendColor:%@",recommendColor.imageColorString);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.posterImageView.mainColor = [UIColor colorFromRGBcode:recommendColor.imageColorString];
            NSLog(@"2");
        });
    }];
    NSLog(@"1");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewDidLoad {
    if(_useCamera){
        [self openCamera];
    }else {
        UIImage *backgroundImage = [UIImage imageNamed:@"pic1.jpg"];
        [self changeBackgroundImage:backgroundImage];
    }
    
}

- (void)openCamera {
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetiFrame1280x720];
    
    self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];;
    [self.device lockForConfiguration:nil];
    
    //    [self.device setActiveVideoMaxFrameDuration:CMTimeMake(1, 60)];
    
    if ([self.device isFlashAvailable]) {
        [self.device setFlashMode:AVCaptureFlashModeOff];
    }
    
    self.videoInput=[[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    self.dataOutPut=[[AVCaptureVideoDataOutput alloc]init];
    [self.dataOutPut setSampleBufferDelegate:(self) queue:self.bufferQueue];
    //    [self.dataOutPut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.contentsScale = [UIScreen mainScreen].scale;
    self.previewLayer.backgroundColor = [[UIColor blackColor]CGColor];
    
    [self.backgroundImageView.layer addSublayer:_previewLayer];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.dataOutPut]) {
        [self.session addOutput:self.dataOutPut];
    }
    
    [self.session startRunning];
}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
//    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVMediaTypeVideo] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    __weak typeof (self) weakSelf = self;
    UIImageWriteToSavedPhotosAlbum([self imageFromSamplePlanerPixelBuffer:sampleBuffer], nil, nil, nil);
    [[self imageFromSamplePlanerPixelBuffer:sampleBuffer] getPaletteImageColor:^(PaletteColorModel *recommendColor, NSDictionary *allModeColorDic, NSError *error) {
//        NSLog(@"colorString:%@",recommendColor.imageColorString);
        if (!recommendColor){
            return;
        }
        weakSelf.posterImageView.mainColor = [UIColor colorFromRGBcode:recommendColor.imageColorString];
    }];
}

 // Create a CGImageRef from sample buffer data
- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    return newImage;
}

- (UIImage *)imageFromSamplePlanerPixelBuffer:(CMSampleBufferRef) sampleBuffer{
    @autoreleasepool {
        // Get a CMSampleBuffer's Core Video image buffer for the media data
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        
        // Get the number of bytes per row for the plane pixel buffer
        void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        
        // Get the number of bytes per row for the plane pixel buffer
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
        // Get the pixel buffer width and height
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        // Create a device-dependent gray color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        // Create a bitmap graphics context with the sample buffer data
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                     bytesPerRow, colorSpace, kCGImageAlphaNone);
        // Create a Quartz image from the pixel data in the bitmap graphics context
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        
        // Free up the context and color space
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        
        // Create an image object from the Quartz image
        UIImage *image = [UIImage imageWithCGImage:quartzImage];
        
        // Release the Quartz image
        CGImageRelease(quartzImage);
        
        return (image);
    }
}

- (CGImageRef)imageFromPixelBuffer:(CMSampleBufferRef)sampleBuffer {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(rgbColorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return cgImage;
}

- (UIImageView *)backgroundImageView {
    if(!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self.view addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}

- (PosterView *)posterImageView {
    if(!_posterImageView) {
        _posterImageView = [[PosterView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 5 * 4, [UIScreen mainScreen].bounds.size.height / 5 * 4)];
        _posterImageView.center = self.backgroundImageView.center;
    }
    return _posterImageView;
}

- (UIButton *)imagePickerButton {
    if(!_imagePickerButton) {
        _imagePickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _imagePickerButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, 100, 100);
        [_imagePickerButton addTarget:self action:@selector(imagePickerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _imagePickerButton.backgroundColor = [UIColor clearColor];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_imagePickerButton addSubview:titleLabel];
        titleLabel.text = @"切换背景";
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        titleLabel.textColor = [UIColor blackColor];
    }
    return _imagePickerButton;
}

- (void)imagePickerButtonClicked {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [self changeBackgroundImage:photos.firstObject];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (UILabel *)testLabel {
    if(!_testLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
        [label setBackgroundColor:[UIColor blackColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setNumberOfLines:0];
        
        NSString *labelText = @"可以自己按照宽高，字体大小，来计算有多少行。。然后。。。每行画一个UILabel。。高度自己可以控制把这个写一个自定义的类。 ";
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineHeightMultiple:0.7];//调整行间距
        label.font = [UIFont systemFontOfSize:30.0f];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
        label.attributedText = attributedString;
        [self.view addSubview:label];
//        [label sizeToFit];
        
        NSLog(@"%f %f",label.frame.size.width,label.frame.size.height);
        _testLabel = label;
    }
    return _testLabel;
}
@end
