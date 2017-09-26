#import <UIKit/UIKit.h>
#import <GPUImage.h>

typedef void(^WmCompleteBlock)(BOOL success);
typedef void(^WmProcessBlock)(CGFloat progress);

@interface VideoFilterController : UIViewController <GPUImageVideoCameraDelegate>

@property (nonatomic, strong) NSURL * videoURL;

@end
