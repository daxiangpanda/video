//
//  RecordVideoControllerViewController.m
//  video
//
//  Created by 刘鑫忠 on 2017/9/20.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import "RecordVideoController.h"
#import <GPUImage.h>

@interface RecordVideoController ()

@end

@implementation RecordVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化 videoCamera
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // 初始化 filter
    filter = [[GPUImageSepiaFilter alloc] init];
    
    [videoCamera addTarget:filter];

//    filterImageView = (GPUImageView *)self.view;
    GPUImageView *filterView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:filterView];

    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];

    blendFilter.mix = 1.0;
    
    NSDate *startTime = [NSDate date];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 240.0f, 320.0f)];
    timeLabel.font = [UIFont systemFontOfSize:17.0f];
    timeLabel.text = @"Time: 0.0 s";
//    timeLabel.textAlignment = UITextAlignmentCenter;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = [UIColor whiteColor];
    
    uiElementInput = [[GPUImageUIElement alloc] initWithView:timeLabel];
    
    [filter addTarget:blendFilter];
    [uiElementInput addTarget:blendFilter];
    
    [blendFilter addTarget:filterView];

    __unsafe_unretained GPUImageUIElement *weakUIElementInput = uiElementInput;
    
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
        timeLabel.text = [NSString stringWithFormat:@"Time: %f s", -[startTime timeIntervalSinceNow]];
        [weakUIElementInput update];
    }];
    
    
    
    // 开始进行相机捕获
    [videoCamera startCameraCapture];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
