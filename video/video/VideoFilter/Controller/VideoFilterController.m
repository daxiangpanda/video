#import "VideoFilterController.h"
#import "HandlerVideo.h"
#import <GPUImage.h>
#import "UIImage+VideoImage.h"
#import "VTTailView.h"
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
    [asset naturalSize];
}
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
    _uiElementInput = [[GPUImageUIElement alloc]initWithView:contentView];
    
    //target
    
    GPUImageAddBlendFilter *addBlendFilter = [[GPUImageAddBlendFilter alloc]init];
    
    GPUImageOutput<GPUImageInput> *blankFilter = [[GPUImageSepiaFilter alloc] init];
    
    [_videoFile addTarget:blankFilter];
    
    [blankFilter addTarget:addBlendFilter];
    
    [_uiElementInput addTarget:addBlendFilter];
    
    [addBlendFilter addTarget:filterView];
    
    [addBlendFilter addTarget:_movieWriter];
    
    __unsafe_unretained GPUImageUIElement *weakUIElementInput = _uiElementInput;
    [blankFilter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
        NSLog(@"%lld_______%d___________%f",frameTime.value,frameTime.timescale,1-(CGFloat)frameTime.value/frameTime.timescale/1.5);
        [weakUIElementInput update];
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
        [self imageVideoToBlurVideo];
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
        [self blurVideoToWaterMarkVideo];
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
    GPUImageGaussianBlurFilter *gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc]init];
    GPUImageOutput<GPUImageInput> *blankFilter = [[GPUImageSepiaFilter alloc] init];
    [_videoFile addTarget:gaussianBlurFilter];
    [gaussianBlurFilter addTarget:blankFilter];
    [blankFilter addTarget:_movieWriter];
    [blankFilter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
//        [uiElementInput update];
        NSLog(@"gaussianBlurFilter   blurRadiusPixels:  __________%f",(CGFloat)frameTime.value/frameTime.timescale/1.5*24);
        [gaussianBlurFilter setBlurRadiusInPixels:(CGFloat)frameTime.value/frameTime.timescale/1.5*24];
    }];
    
    [_movieWriter startRecording];
    
    [_videoFile startProcessing];
    
    //    __unsafe_unretained GPUImageMovieWriter *weakMovieWriter = _movieWriter;
    
    KWS(weakSelf);
    [self.movieWriter setCompletionBlock:^{
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
    NSString *videoName = [NSString stringWithFormat:@"blurVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
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
    _filter = [[GPUImageSepiaFilter alloc] init];
    [_videoFile addTarget:_filter];
    [_filter addTarget:addBlendFilter];
    [uielement addTarget:addBlendFilter];
    [addBlendFilter addTarget:_movieWriter];

    [_filter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
        NSLog(@"%f",(CGFloat)frameTime.value/frameTime.timescale/1.5);
        tailView.waterMarkAlpha = (CGFloat)frameTime.value/frameTime.timescale/1.5;
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
