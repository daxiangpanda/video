#import <UIKit/UIKit.h>
#import <GPUImage.h>

typedef void(^WmCompleteBlock)(BOOL success, NSString *errorMsg);
typedef void(^WmProcessBlock)(CGFloat progress);

@interface VideoFilterController : UIViewController <GPUImageVideoCameraDelegate>{
//    GPUImageOutput<GPUImageInput>   *filter;
//    GPUImageView                    *filterImageView;
//    GPUImageMovie                   *videoFile;
//    GPUImageUIElement               *uiElementInput;
//    GPUImageMovieWriter             *movieWriter;

    
}

@property (nonatomic, strong) NSURL * videoURL;

@end
