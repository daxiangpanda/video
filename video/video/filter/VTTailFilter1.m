//
//  VTTailFilter1.m
//  vtell
//
//  Created by 刘鑫忠 on 2017/10/16.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "VTTailFilter1.h"
#import "VTTailView.h"
@implementation VTTailFilter1
{
    GPUImageBrightnessFilter *filter ;
    GPUImageOverlayBlendFilter *addBlendFilter ;
    GPUImageUIElement *uielement ;
}
- (id)init
{
    if(!(self = [super init]))
    {
        return nil;
    }
    return self;
}

- (void)setLastFrameImage:(UIImage *)lastFrameImage userName:(NSString *)userName {
    filter = [[GPUImageBrightnessFilter alloc]init];
    addBlendFilter = [[GPUImageOverlayBlendFilter alloc]init];
    uielement = [[GPUImageUIElement alloc]initWithView:[[UIImageView alloc]initWithImage:lastFrameImage]];
    CGSize tailViewSize = lastFrameImage.size;
    
    VTTailView *tailView = [[VTTailView alloc]initWithFrame:CGRectMake(0, 0, tailViewSize.width, tailViewSize.height)];
    tailView.alpha = 0;
    tailView.userName = userName;
    
    [self addFilter:filter];
    [self addFilter:addBlendFilter];

    
    [filter addTarget:addBlendFilter];
    
    [uielement addTarget:addBlendFilter];
    
    [self setInitialFilters:[NSArray arrayWithObjects:filter, nil]];
    [self setTerminalFilter:addBlendFilter];
    __unsafe_unretained GPUImageUIElement *weakUIE = uielement;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime time) {
        [uielement update];
    }];
    
    CGFloat tailVideoTime = 1.50f;
    
//    [blurBlankFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime time) {
//        //        if(round(((CGFloat)time.value)/time.timescale/tailVideoTime*6) != blurFilter.blurRadiusInPixels){
//        //            dispatch_sync(dispatch_get_main_queue(), ^{
//        //Update UI in UI thread here
//        //                ((UILabel*)[tailView userNameLabel]).text = [NSString stringWithFormat:@"导演•%@",userName];
//        [tailView setAlpha:((CGFloat)time.value)/time.timescale/tailVideoTime];
//        //            });
//        [blurFilter setBlurRadiusInPixels:((CGFloat)time.value)/time.timescale/tailVideoTime * 6];
//        [uielement update];
//        [waterMarkUIElement update];
//        //        }
//    }];
}
@end
