#import "VideoFilterController.h"
#import "HandlerVideo.h"
#import <GPUImage.h>

@interface VideoFilterController ()

@end

@implementation VideoFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    //生成一个黑色的视频
    CGSize videoSize = CGSizeMake(720, 720);
    CGFloat time = 1.5;
    CGFloat fps = 30;
    [[HandlerVideo sharedInstance]createBlackVideo:videoSize time:time fps:fps progressImageBlock:nil completedBlock:nil];
    NSString *videoName = [NSString stringWithFormat:@"blackVideo%.0f*%.0f %.2fs.mp4",videoSize.width,videoSize.height,time];
    NSArray *sandboxPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = [sandboxPaths.firstObject stringByAppendingPathComponent:videoName];
    //读取黑色视频
    videoFile = [[GPUImageMovie alloc]initWithURL:[NSURL URLWithString:path]];
    // 初始化 videoCamera
    
    // 初始化 filter
    filter = [[GPUImageSepiaFilter alloc] init];
    
    [videoFile addTarget:filter];

//    filterImageView = (GPUImageView *)self.view;
    GPUImageView *filterView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:filterView];

    [filter addTarget:filterView];

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
