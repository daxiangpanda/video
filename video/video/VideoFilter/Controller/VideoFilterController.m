#import "VideoFilterController.h"
#import "HandlerVideo.h"
#import <GPUImage.h>
#import "UIImage+VideoImage.h"
#import "VTTailView.h"

@interface VideoFilterController ()

@property (nonatomic, strong) UIVisualEffectView          *visualEffectView;

@end

@implementation VideoFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.visualEffectView.frame = self.view.frame;

    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview: filterView];
    
    //生成一个黑色的视频
    CGSize videoSize = CGSizeMake(720, 540);
    CGFloat time = 1.5;
    CGFloat fps = 30;
    [[HandlerVideo sharedInstance]createBlackVideo:videoSize time:time fps:fps progressImageBlock:nil completedBlock:nil];
    NSString *videoName = [NSString stringWithFormat:@"blackVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *videoPath = [NSString stringWithFormat:@"Documents/%@",videoName];

    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:videoPath];
    //配置movieWriter
    
    
    
    NSString *lastFrameVideoName = [NSString stringWithFormat:@"lastFrameVideo%.0f*%.0f%.2fs.mp4",videoSize.width,videoSize.height,time];
    NSString *lastFrameMoviePath = [NSHomeDirectory() stringByAppendingPathComponent:lastFrameVideoName];
    NSURL *lastFrameVideoURL= [NSURL fileURLWithPath:lastFrameMoviePath];

    if([[NSFileManager defaultManager] fileExistsAtPath:lastFrameMoviePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:lastFrameMoviePath error:nil];
    }
    movieWriter = [[GPUImageMovieWriter alloc]initWithMovieURL:lastFrameVideoURL size:CGSizeMake(720, 540)];
    
    movieWriter.hasAudioTrack = YES;
    
    movieWriter.shouldPassthroughAudio = YES;
    //读取黑色视频
    NSURL *sampleURL = [NSURL fileURLWithPath:pathToMovie];
    
    videoFile = [[GPUImageMovie alloc]initWithURL:sampleURL];
    
    NSString* testVideoPath = [[NSBundle mainBundle]pathForResource:@"testVideo1" ofType:@"mp4"];

    VTTailView *tailView = [[VTTailView alloc]initWithFrame:CGRectMake(0, 0, 720, 540)];
    
    CGFloat videoLength = [self getVideoLength:[NSURL fileURLWithPath:testVideoPath]];

    UIImage *lastImage = [UIImage thumbnailImageForVideo:[NSURL fileURLWithPath:testVideoPath] atTime:videoLength*fps];
    
    tailView.lastFrameImage = lastImage;
    
    tailView.userName = @"大师";
    
    GPUImageUIElement *UIElement = [[GPUImageUIElement alloc]initWithView:tailView];
    
    GPUImageAddBlendFilter *addBlendFilter = [[GPUImageAddBlendFilter alloc]init];
    
    filter = [[GPUImageSepiaFilter alloc] init];
    
//    __unsafe_unretained ShowcaseFilterViewController * weakSelf = self;

    
    [videoFile addTarget:filter];

    [filter addTarget:addBlendFilter];
    
    [UIElement addTarget:addBlendFilter];
    
    [addBlendFilter addTarget:filterView];
    
    
    [addBlendFilter addTarget:movieWriter];
//    __unsafe_unretained GPUImageUIElement *weakUIE = UIElement;
//    [UIView animateKeyframesWithDuration:100 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        [tailView.visualEffectView setEffect:blurEffect];
//    } completion:nil];
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput * filter, CMTime frameTime){
        NSLog(@"%lld_______%d___________%f",frameTime.value,frameTime.timescale,1-(CGFloat)frameTime.value/frameTime.timescale/1.5);
        //imageView 1s模糊
        //waterMark 1s显示
//        tailView.virtualEffectAlpha = (CGFloat)frameTime.value/frameTime.timescale/1.5;
//
//        tailView.waterMarkAlpha = (CGFloat)frameTime.value/frameTime.timescale/1.5;

        [UIElement update];
    }];
//    [filter addTarget:filterView];
    
//    [movieWriter startRecording];
    
    [videoFile startProcessing];

    __unsafe_unretained GPUImageMovieWriter *weakMovieWriter = movieWriter;

    [movieWriter setCompletionBlock:^{
        [weakMovieWriter finishRecording];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    }];

    [self.view addSubview:self.visualEffectView];
        [UIView animateKeyframesWithDuration:5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            [self.visualEffectView setEffect:blurEffect];
        } completion:nil];
}

- (UIVisualEffectView *)visualEffectView {
    if (_visualEffectView == nil) {
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                _visualEffectView.alpha = 1;
        _visualEffectView.backgroundColor = [UIColor clearColor];
        _visualEffectView.userInteractionEnabled = NO;
    }
    return _visualEffectView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (CGFloat)getVideoLength:(NSURL *)url{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
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
