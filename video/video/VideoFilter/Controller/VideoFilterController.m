#import "VideoFilterController.h"
#import "HandlerVideo.h"
#import <GPUImage.h>
#import "UIImage+VideoImage.h"
#import "VTTailView.h"
#import "VTWaterMarkView.h"

#define KWS(weakSelf)           __weak __typeof(&*self)weakSelf = self

@interface VideoFilterController ()

@property (nonatomic, strong) NSURL                           *imageVideoURL;
@property (nonatomic, strong) NSURL                           *blurVideoURL;
@property (nonatomic, strong) NSURL                           *waterMarkVideoURL;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput>   *filter;
@property (nonatomic, strong) GPUImageView                    *filterImageView;
@property (nonatomic, strong) GPUImageMovie                   *videoFile;
@property (nonatomic, strong) GPUImageUIElement               *uiElementInput;
@property (nonatomic, strong) GPUImageMovieWriter             *movieWriter;

@end

@implementation VideoFilterController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* testVideoPath = [[NSBundle mainBundle]pathForResource:@"testVideo1" ofType:@"mp4"];

    _videoURL = [NSURL fileURLWithPath:testVideoPath];
    
//    [self midWaterMarkVideo:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"testVideo1" ofType:@"mp4"]]videoSize:CGSizeMake(720, 540)];
    [self blackVideoToImageVideo];
//
}

- (CGFloat)getVideoLength:(NSURL *)url{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (void)waterMarkVideo:(NSURL*)videoURL
        completedBlock:(WmCompleteBlock)completeBlock
          processBlock:(WmProcessBlock)processBlock {
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize videoSize = [videoTrack naturalSize];
    
    
}

//给视频加上视频中水印
//IP7P 2s-3s
- (void)midWaterMarkVideo:(NSURL*)videoURL videoSize:(CGSize)videoSize{
    NSLog(@"start");
    _videoFile = [[GPUImageMovie alloc]initWithURL:videoURL];
    _videoFile.playAtActualSpeed = NO;
    GPUImageOutput<GPUImageInput> *filter = [[GPUImageBrightnessFilter alloc] init];
    
    [_videoFile addTarget:filter];
    
    GPUImageAddBlendFilter *blendFilter = [[GPUImageAddBlendFilter alloc] init];
    
    VTWaterMarkView *waterMarkView = [[VTWaterMarkView alloc]initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
    waterMarkView.userName = @"test测试名字";
    GPUImageUIElement *uiElementInput = [[GPUImageUIElement alloc] initWithView:waterMarkView];
    NSString *videoName = [[videoURL path] componentsSeparatedByString:@"/"].lastObject;
    NSString *path = [NSString stringWithFormat:@"Documents/%@water",videoName];
    NSString *wateredVideoPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    NSURL *wateredVideoURL = [NSURL fileURLWithPath:wateredVideoPath];
    unlink([wateredVideoPath UTF8String]);
    _movieWriter = nil;
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:wateredVideoURL size:videoSize];
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:wateredVideoURL
                                                           size:videoSize
                                                       fileType:AVFileTypeQuickTimeMovie
                                                 outputSettings:nil];
    _movieWriter.shouldPassthroughAudio = YES;
    _videoFile.audioEncodingTarget = _movieWriter;
    [_videoFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    NSLog(@"%@", wateredVideoURL);
//    [filter addTarget:_movieWriter];
    [filter addTarget:blendFilter];
    [uiElementInput addTarget:blendFilter];
    [blendFilter addTarget:_movieWriter];
    
    //下面一行是啥意思？不同的地方写还是不写？
//        __unsafe_unretained GPUImageUIElement *weakUIE = uiElementInput;
//    [uiElementInput update];
    __block BOOL needUpdate = YES;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
        if(needUpdate){
            [uiElementInput update];
            needUpdate = !needUpdate;
        }
    }];

    [_movieWriter startRecording];
    
    [_videoFile startProcessing];
    
    __unsafe_unretained GPUImageMovieWriter *weakMovieWriter = _movieWriter;
    
    [_movieWriter setCompletionBlock:^{
        NSLog(@"END");
        [filter removeTarget:weakMovieWriter];
        [weakMovieWriter finishRecording];
    }];
}

//- (void)completionWriter5{
//    KWS(weakSelf);
//    [_movieWriter finishRecordingWithCompletionHandler:^{
//        [weakSelf finishRecording5];
//    }];
//}
//
//- (void)finishRecording5{
//    dispatch_async(dispatch_get_main_queue(), ^{
//    });
//}


- (void)blackVideoToImageVideo {
    double start = [[NSDate date] timeIntervalSince1970]*1000;
    NSLog(@"blackVideoToImageVideo start time= %f ", (start));
        GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
        [self.view addSubview: filterView];
    //生成黑色视频
    CGSize videoSize = CGSizeMake(720, 540);
    CGFloat time = 1.5;
    CGFloat fps = 30;
    [[HandlerVideo sharedInstance]createBlackVideo:videoSize time:time fps:fps progressImageBlock:nil completedBlock:nil];
    NSString *videoName = [NSString stringWithFormat:@"blackVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *videoPath = [NSString stringWithFormat:@"Documents/%@",videoName];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:videoPath];
    
    _videoFile = [[GPUImageMovie alloc]initWithURL:[NSURL fileURLWithPath:pathToMovie]];
    //配置movieWriter
    NSString *lastFrameVideoName = [NSString stringWithFormat:@"imageVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *lastFrameMoviePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",lastFrameVideoName]];
    NSURL *lastFrameVideoURL= [NSURL fileURLWithPath:lastFrameMoviePath];
    self.imageVideoURL = lastFrameVideoURL;
    if([[NSFileManager defaultManager] fileExistsAtPath:lastFrameMoviePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:lastFrameMoviePath error:nil];
    }
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:lastFrameVideoURL size:videoSize];
    
    _movieWriter.hasAudioTrack = YES;
    
    _movieWriter.shouldPassthroughAudio = YES;
    
    NSString* testVideoPath = [[NSBundle mainBundle]pathForResource:@"testVideo1" ofType:@"mp4"];

    //生成最后一帧的图片
    CGFloat videoLength = [self getVideoLength:[NSURL fileURLWithPath:testVideoPath]];
    
    UIImage *lastImage = [UIImage thumbnailImageForVideo:[NSURL fileURLWithPath:testVideoPath] atTime:videoLength*fps];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:lastImage];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
    [contentView addSubview:imageView];
//    UILabel *label = [[UILabel alloc]initWithFrame:contentView.frame];
    
    _uiElementInput = [[GPUImageUIElement alloc]initWithView:contentView];
    
    //target
    
    GPUImageAddBlendFilter *addBlendFilter = [[GPUImageAddBlendFilter alloc]init];
    
    GPUImageBrightnessFilter *blankFilter = [[GPUImageBrightnessFilter alloc] init];
    blankFilter.brightness = 0;
    
    //blur
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc]init];
    [blurFilter setBlurRadiusInPixels:0];
    
    
    //waterMarkElement
    UIView *waterMarkContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
    VTTailView *tailView = [[VTTailView alloc]initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
    
    
//    UILabel *testLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
//    testLabel.font = [UIFont systemFontOfSize:50.0f];
//    testLabel.text = @"Time: 0.0 s";
//    testLabel.textAlignment = UITextAlignmentCenter;
//    testLabel.backgroundColor = [UIColor clearColor];
//    testLabel.textColor = [UIColor whiteColor];
//    testLabel.alpha = 0;
//    tailView.userName = @"sa";
    [waterMarkContentView addSubview:tailView];
    
    GPUImageUIElement *waterMarkUIElement = [[GPUImageUIElement alloc]initWithView:waterMarkContentView];
    
    GPUImageAddBlendFilter *waterMarkBlendFilter = [[GPUImageAddBlendFilter alloc]init];
    GPUImageOutput<GPUImageInput> *blankFilter2 = [[GPUImageSepiaFilter alloc] init];


//    [blurFilter addTarget:_movieWriter];
//    [blurFilter addTarget:filterView];
//
//    [addBlendFilter addTarget:_movieWriter];
    
    //alltarget
//    [_videoFile addTarget:blankFilter];
//    
//    [blankFilter addTarget:addBlendFilter];
//    
//    [_uiElementInput addTarget:addBlendFilter];
//    [addBlendFilter addTarget:blurFilter];
//    [blurFilter addTarget:blankFilter2];
//    [ blankFilter2 addTarget:waterMarkBlendFilter];
//    [waterMarkUIElement addTarget:waterMarkBlendFilter];
//    
//    [waterMarkBlendFilter addTarget:_movieWriter];
//    [waterMarkBlendFilter addTarget:filterView];
    
    //alltarget3
    [_videoFile addTarget:blankFilter];
    
    [blankFilter addTarget:addBlendFilter];
    
    [_uiElementInput addTarget: addBlendFilter];
    [addBlendFilter addTarget:blurFilter];
    
//    [blurFilter addTarget:waterMarkBlendFilter];
//     addTarget:blankFilter2];
//    [ blankFilter2 addTarget:waterMarkBlendFilter];
//    [waterMarkUIElement addTarget:waterMarkBlendFilter];
    
    [blurFilter addTarget:_movieWriter];
    [blurFilter addTarget:filterView];
    
    //alltarget2
    
//    [_videoFile addTarget:blankFilter];
//    [blankFilter addTarget:addBlendFilter];
//    [waterMarkUIElement addTarget:addBlendFilter];
//    [addBlendFilter addTarget:waterMarkBlendFilter];
//    [_uiElementInput addTarget:waterMarkBlendFilter];
//    [waterMarkBlendFilter addTarget:blurFilter];
//    [blurFilter addTarget:_movieWriter];
//    [blurFilter addTarget:filterView];
    
    __block GPUImageUIElement *weakUIElementInput = _uiElementInput;
    __block GPUImageUIElement *weakWaterMarkUIElement = waterMarkUIElement;
    __block UIView            *weakWaterContentView = waterMarkContentView;
    __block GPUImageGaussianBlurFilter *weakBlurFilter = blurFilter;
    [blankFilter setFrameProcessingCompletionBlock:^(GPUImageOutput * blankFilter, CMTime frameTime){
        NSLog(@"%lld_______%d___________%f",frameTime.value,frameTime.timescale,(CGFloat)frameTime.value/frameTime.timescale/1.5*24);
        if(weakBlurFilter.blurRadiusInPixels < 16){
            [weakBlurFilter setBlurRadiusInPixels:(CGFloat)frameTime.value/frameTime.timescale/1.5*24];
            NSLog(@"%f",weakBlurFilter.blurRadiusInPixels);
        }
        [weakUIElementInput update];
//        weakWaterContentView.alpha = (CGFloat)frameTime.value/frameTime.timescale/1.5;
//        NSLog()
//        if(frameTime.value>400){
//            tailView.userName = @"taikdsa";
//        }
//        testLabel.text = [NSString stringWithFormat:@"%lld",frameTime.value ];
//        testLabel.alpha = (CGFloat)frameTime.value/frameTime.timescale/1.5;
        
//        [weakWaterMarkUIElement update];
    }];
    


    
    [_movieWriter startRecording];
    
    [_videoFile startProcessing];
    
//    __unsafe_unretained GPUImageMovieWriter *weakMovieWriter = _movieWriter;
    
    KWS(weakSelf);
    [self.movieWriter setCompletionBlock:^{
        [weakSelf completionWriter1];
    }];

}

- (void)completionWriter1{
    KWS(weakSelf);
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf finishRecording1];
    }];
}

- (void)finishRecording1{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self blurVideoToWaterMarkVideo];
    });
}

- (void)completionWriter2{
    KWS(weakSelf);
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf finishRecording2];
    }];
}

- (void)finishRecording2{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self blurVideoToWaterMarkVideo];
    });
}

- (void)imageVideoToBlurVideo {
    [_videoFile removeAllTargets];
    [_filter removeAllTargets];
    //输入
    CGSize videoSize = CGSizeMake(720, 540);
    CGFloat time = 1.5;
    CGFloat fps = 30;
    NSString *videoName = [NSString stringWithFormat:@"imageVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *videoPath = [NSString stringWithFormat:@"Documents/%@",videoName];

    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:videoPath];
    
    _videoFile = [[GPUImageMovie alloc]initWithURL:[NSURL fileURLWithPath:pathToMovie]];

    //输出
    NSString *blurVideoName = [NSString stringWithFormat:@"blurVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *blurMoviePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",blurVideoName]];
    NSURL *blurVideoURL= [NSURL fileURLWithPath:blurMoviePath];
    self.blurVideoURL = blurVideoURL;
    if([[NSFileManager defaultManager] fileExistsAtPath:blurMoviePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:blurMoviePath error:nil];
    }
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:blurVideoURL size:videoSize];

    _movieWriter.hasAudioTrack = YES;
    
    _movieWriter.shouldPassthroughAudio = YES;
//
//    //target
    
    VTWaterMarkView *tailView = [[VTWaterMarkView alloc]initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
    GPUImageAddBlendFilter *addBlendFilter = [[GPUImageAddBlendFilter alloc]init];
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc]initWithView:tailView];
    tailView.userName = @"大兄弟撒女方";
    _filter = [[GPUImageSepiaFilter alloc] init];
    
//    _uiElementInput = [GPUImageUIElement alloc]initWithView:<#(UIView *)#>
    GPUImageGaussianBlurFilter *gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc]init];
    GPUImageOutput<GPUImageInput> *blankFilter = [[GPUImageSepiaFilter alloc] init];
    [_videoFile addTarget:gaussianBlurFilter];
    [gaussianBlurFilter addTarget:blankFilter];
    [blankFilter addTarget:addBlendFilter];
    [uielement addTarget:addBlendFilter];
    [addBlendFilter addTarget:_movieWriter];
//    __block GPUImageUIElement *weakUIElementInput = uielement;
    [blankFilter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
        NSLog(@"gaussianBlurFilter   blurRadiusPixels:  __________%f",(CGFloat)frameTime.value/frameTime.timescale/1.5*24);
        [gaussianBlurFilter setBlurRadiusInPixels:(CGFloat)frameTime.value/frameTime.timescale/1.5*24];
        tailView.alpha = (CGFloat)frameTime.value/frameTime.timescale;
        [uielement update];
    }];
    
    [_movieWriter startRecording];
    
    [_videoFile startProcessing];
    
    //    __unsafe_unretained GPUImageMovieWriter *weakMovieWriter = _movieWriter;
    
    KWS(weakSelf);
    [self.movieWriter setCompletionBlock:^{
        NSLog(@"done");
        [weakSelf completionWriter2];
    }];
}

- (void)blurVideoToWaterMarkVideo {
    [_videoFile removeAllTargets];
    [_filter removeAllTargets];
    //输入
    CGSize videoSize = CGSizeMake(720, 540);
    CGFloat time = 1.5;
    CGFloat fps = 30;
    NSString *videoName = [NSString stringWithFormat:@"imageVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *videoPath = [NSString stringWithFormat:@"Documents/%@",videoName];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:videoPath];
    
    _videoFile = [[GPUImageMovie alloc]initWithURL:[NSURL fileURLWithPath:pathToMovie]];
    
    //输出
    NSString *waterMarkVideoName = [NSString stringWithFormat:@"waterMarkVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *waterMarkMoviePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",waterMarkVideoName]];
    NSURL *waterMarkVideoURL= [NSURL fileURLWithPath:waterMarkMoviePath];
    self.waterMarkVideoURL = waterMarkVideoURL;
    if([[NSFileManager defaultManager] fileExistsAtPath:waterMarkMoviePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:waterMarkMoviePath error:nil];
    }
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:waterMarkVideoURL size:videoSize];
    
    _movieWriter.hasAudioTrack = YES;
    
    _movieWriter.shouldPassthroughAudio = YES;
    //
    //target
    
    VTTailView *tailView = [[VTTailView alloc]initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
    GPUImageAddBlendFilter *addBlendFilter = [[GPUImageAddBlendFilter alloc]init];
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc]initWithView:tailView];
    GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
    filter.brightness = 0;
    [_videoFile addTarget:filter];
    [filter addTarget:addBlendFilter];
    [uielement addTarget:addBlendFilter];
    [addBlendFilter addTarget:_movieWriter];

    [_filter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
        NSLog(@"%f",(CGFloat)frameTime.value/frameTime.timescale/1.5);
        tailView.alpha = (CGFloat)frameTime.value/frameTime.timescale/1.5;
        
        [uielement update];

    }];
    
    [_movieWriter startRecording];
    
    [_videoFile startProcessing];
    
    KWS(weakSelf);
    [self.movieWriter setCompletionBlock:^{
        [weakSelf completionWriter3];
    }];
}

- (void)completionWriter3{
    KWS(weakSelf);
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf finishRecording3];
    }];
}

- (void)finishRecording3{
    dispatch_async(dispatch_get_main_queue(), ^{
//        UISaveVideoAtPathToSavedPhotosAlbum([filePath path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);

    });
}

//
//    [movieWriter startRecording];
//    
//    [videoFile startProcessing];
//    
//    __unsafe_unretained GPUImageMovieWriter *weakMovieWriter = movieWriter;
//    
//    [movieWriter setCompletionBlock:^{
//        [weakMovieWriter finishRecording];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//        });
//    }];
//}

//- (void)blurVideoToWaterMarkVideo {
//    
//}



- (NSURL*)imageVideoURL {
    if(!_imageVideoURL) {
        _imageVideoURL = [[NSURL alloc]init];
    }
    return _imageVideoURL;
}

- (NSURL*)blurVideoURL {
    if(!_blurVideoURL) {
        _blurVideoURL = [[NSURL alloc]init];
    }
    return _blurVideoURL;
}

- (NSURL*)waterMarkVideoURL {
    if(!_waterMarkVideoURL) {
        _waterMarkVideoURL = [[NSURL alloc]init];
    }
    return _waterMarkVideoURL;
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
