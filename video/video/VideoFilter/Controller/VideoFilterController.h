#import <UIKit/UIKit.h>
#import <GPUImage.h>

@interface VideoFilterController : UIViewController <GPUImageVideoCameraDelegate>
{
    GPUImageOutput<GPUImageInput>   *filter;
    GPUImageView                    *filterImageView;
    GPUImageMovie                   *videoFile;
    GPUImageUIElement               *uiElementInput;
}

@end