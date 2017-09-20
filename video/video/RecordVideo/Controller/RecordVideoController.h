//
//  RecordVideoControllerViewController.h
//  video
//
//  Created by 刘鑫忠 on 2017/9/20.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GPUImage.h>

@interface RecordVideoController : UIViewController <GPUImageVideoCameraDelegate>
{
    GPUImageOutput<GPUImageInput>   *filter;
    GPUImageView                    *filterImageView;
    GPUImageVideoCamera             *videoCamera;
    GPUImageUIElement *uiElementInput;

}

@end
