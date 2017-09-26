
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
@property (nonatomic, strong) NSURL                           *midVideoURL;
@property (nonatomic, assign) CGSize                          videoSize;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput>   *filter;
@property (nonatomic, strong) GPUImageView                    *filterImageView;
@property (nonatomic, strong) GPUImageMovie                   *videoFile;
@property (nonatomic, strong) GPUImageUIElement               *uiElementInput;
@property (nonatomic, strong) GPUImageMovieWriter             *movieWriter;
@property (nonatomic, strong) GPUImageMovieWriter             *movieWriter2;

@end

@implementation VideoFilterController


//- (instancetype)init

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* testVideoPath = [[NSBundle mainBundle]pathForResource:@"testVideo1" ofType:@"mp4"];

    _videoURL = [NSURL fileURLWithPath:testVideoPath];
    
//    [self midWaterMarkVideo:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"testVideo1" ofType:@"mp4"]]videoSize:CGSizeMake(720, 540)];
//    [self blackVideoToImageVideo];
//
//    整个流程 ip7p 3s  ip5c 12s
    [self waterMarkVideo:_videoURL completedBlock:nil processBlock:nil];
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
    _videoSize = [videoTrack naturalSize];    KWS(weakSelf);
    [self midWaterMarkVideo:videoURL videoSize:_videoSize];
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
//    NSString *videoName = [[videoURL path] componentsSeparatedByString:@"/"].lastObject;
    NSString *path = [NSString stringWithFormat:@"Documents/midVideo.mp4"];
    NSString *wateredVideoPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    NSURL *wateredVideoURL = [NSURL fileURLWithPath:wateredVideoPath];
    unlink([wateredVideoPath UTF8String]);
    _movieWriter = nil;
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:wateredVideoURL size:videoSize];
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:wateredVideoURL
                                                           size:videoSize
                                                       fileType:AVFileTypeQuickTimeMovie
                                                 outputSettings:nil];
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: filterView];
    _midVideoURL = wateredVideoURL;
    _movieWriter.shouldPassthroughAudio = YES;
    _videoFile.audioEncodingTarget = _movieWriter;
    [_videoFile enableSynchronizedEncodingUsingMovieWriter:_movieWriter];
    NSLog(@"%@", wateredVideoURL);
//    [filter addTarget:_movieWriter];
    [filter addTarget:blendFilter];
    [uiElementInput addTarget:blendFilter];
    [blendFilter addTarget:_movieWriter];
//    [blendFilter addTarget:filterView];
    //下面一行是啥意思？不同的地方写还是不写？
//        __unsafe_unretained GPUImageUIElement *weakUIE = uiElementInput;
//    [uiElementInput update];
//    __block BOOL needUpdate = YES;
//    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
//        NSLog(@"%lld",frameTime.value);
//        if((CGFloat)frameTime.value/frameTime.timescale<0.1){
//            [uiElementInput update];
//        }
//    }];
    
    //
    
    __unsafe_unretained GPUImageUIElement *weakOverlay = uiElementInput;
    
    [blendFilter disableSecondFrameCheck];//这样只是在需要更新水印的时候检查更新就不会调用很多次
    
    runAsynchronouslyOnVideoProcessingQueue(^{
        
        [weakOverlay update];
        
    });

    [_movieWriter startRecording];
    
    [_videoFile startProcessing];
    
    __unsafe_unretained GPUImageMovieWriter *weakMovieWriter = _movieWriter;
    KWS(weakSelf);
    [_movieWriter setCompletionBlock:^{
        NSLog(@"END");
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
        [self blackVideoToImageVideo];
    });
}

- (void)blackVideoToImageVideo{
    _videoFile = nil;
    _movieWriter2 = nil;
    _uiElementInput = nil;
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
    GPUImageBrightnessFilter *blankFilter = [[GPUImageBrightnessFilter alloc] init];
    blankFilter.brightness = 0;
    [_videoFile addTarget:blankFilter];
    
    //配置movieWriter
    NSString *lastFrameVideoName = [NSString stringWithFormat:@"imageVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *lastFrameMoviePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",lastFrameVideoName]];
    NSURL *lastFrameVideoURL= [NSURL fileURLWithPath:lastFrameMoviePath];
    self.imageVideoURL = lastFrameVideoURL;
    if([[NSFileManager defaultManager] fileExistsAtPath:lastFrameMoviePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:lastFrameMoviePath error:nil];
    }

//
    NSString* testVideoPath = [[NSBundle mainBundle]pathForResource:@"testVideo1" ofType:@"mp4"];
    CGFloat videoLength = [self getVideoLength:[NSURL fileURLWithPath:testVideoPath]];
    
    UIImage *lastImage = [UIImage thumbnailImageForVideo:[NSURL fileURLWithPath:testVideoPath] atTime:videoLength*fps];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:lastImage];
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
    [contentView addSubview:imageView];
    
    
    // 2
    _uiElementInput = [[GPUImageUIElement alloc]initWithView:contentView];
    GPUImageAddBlendFilter *addBlendFilter = [[GPUImageAddBlendFilter alloc]init];
    
    
    // 3.
    [_uiElementInput addTarget:addBlendFilter];
    [blankFilter addTarget:addBlendFilter];
    
    
    KWS(weakSelf);
    [blankFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [weakSelf.uiElementInput update];
    }];
    //addBlendFilter
    
//
    //blur
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc]init];
    [blurFilter setBlurRadiusInPixels:0];
    [addBlendFilter addTarget:blurFilter];

    VTTailView *tailView = nil;
    CGFloat r = 0.0f;
    CGRect rect = CGRectZero;
    if(videoSize.height<videoSize.width){
        r = videoSize.height/281;
        rect = CGRectMake((videoSize.width-375*r)/2*r,1*r, 710, 530);
        if(rect.origin.x<1.0f){
            rect.origin.x = 1.0f;
        }
        if(rect.origin.y<1.0f){
            rect.origin.y = 1.0f;
        }

    }else {
        r = videoSize.width/375;
        rect = CGRectMake(1*r,(videoSize.height-281*r)/2*r, 375*r, 281*r);
        if(rect.origin.x<1.0f){
            rect.origin.x = 1.0f;
        }
        if(rect.origin.y<1.0f){
            rect.origin.y = 1.0f;
        }
    }
    
    tailView = [[VTTailView alloc]initWithFrame:rect];
    tailView.userName = @"adsdsafc";
    tailView.alpha = 0;
    GPUImageUIElement *  uiElementInputLabel = [[GPUImageUIElement alloc]initWithView:tailView];
    GPUImageAddBlendFilter *addBlendFilterLABEL = [[GPUImageAddBlendFilter alloc]init];
    
   
    
    [uiElementInputLabel addTarget:addBlendFilterLABEL];
    [blurFilter addTarget:addBlendFilterLABEL];

    [blurFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        tailView.alpha = time.value/900.0;
        [blurFilter setBlurRadiusInPixels:time.value/900.0 * 6];
        [uiElementInputLabel update];
    }];

    _movieWriter = nil;
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:lastFrameVideoURL size:videoSize];
    _movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:lastFrameVideoURL
                                                           size:videoSize
                                                       fileType:AVFileTypeQuickTimeMovie
                                                 outputSettings:nil];
    _waterMarkVideoURL = lastFrameVideoURL;

//    [addBlendFilterLABEL addTarget:filterView];
    [addBlendFilterLABEL addTarget:_movieWriter];
    [_movieWriter startRecording];
    [_videoFile startProcessing];
    
    [_movieWriter setCompletionBlock:^{
        NSLog(@"done");
        [weakSelf completionWriter2];
    }];
}



- (void)completionWriter2{
    KWS(weakSelf);
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [weakSelf finishRecording2];
    }];
}

- (void)finishRecording2{
    KWS(weakSelf);

    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf exportVideos:^(BOOL success) {
            if(success){
                NSLog(@"合并完成");
            }
        }];
    });
}

- (void)exportVideos:(WmCompleteBlock)completeBlock{
    NSURL *midVideoURL = _midVideoURL;
    NSURL *waterMarkVideoURL = _waterMarkVideoURL;

    NSArray *urlArray = [[NSArray alloc]initWithObjects:midVideoURL, waterMarkVideoURL,nil];
    NSString *outName = [NSString stringWithFormat:@"outVideo.mp4"];
    NSString *outPath = [NSString stringWithFormat:@"Documents/%@",outName];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:outPath];
    if([[NSFileManager defaultManager]fileExistsAtPath:outPath]){
        [[NSFileManager defaultManager]removeItemAtPath:outPath error:nil];
    }
    unlink([outPath UTF8String]);
    NSURL *outputUrl = [NSURL fileURLWithPath:pathToMovie];
    CMTime cursorTime = kCMTimeZero;
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *videoAssetTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioAssetTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    for (NSURL *url  in urlArray) {
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        if(videoTrack!=nil){
            [videoAssetTrack insertTimeRange:CMTimeRangeFromTimeToTime(CMTimeMake(2, 30),CMTimeSubtract(videoTrack.timeRange.duration, CMTimeMake(2, 30))) ofTrack:videoTrack atTime:cursorTime error:nil];
        }
        if(audioTrack!=nil){
            [audioAssetTrack insertTimeRange:CMTimeRangeFromTimeToTime(CMTimeMake(2, 30),CMTimeSubtract(videoTrack.timeRange.duration, CMTimeMake(2, 30))) ofTrack:audioTrack atTime:cursorTime error:nil];
        }
        cursorTime = CMTimeAdd(cursorTime, CMTimeSubtract(videoTrack.timeRange.duration, CMTimeMake(4, 30)));
    }

    static void *ExportProcess = &ExportProcess;
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = outputUrl;
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if(completeBlock){
            completeBlock(YES);
        }
    }];
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
