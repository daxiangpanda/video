//
//  VTMidWaterMarkFilter.m
//  vtell
//
//  Created by 刘鑫忠 on 2017/10/12.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "VTMidWaterMarkFilter.h"
#import "VTWaterMarkView.h"

@implementation VTMidWaterMarkFilter
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

- (void)setUserName:(NSString *)userName {
    _userName = userName;
}

- (void)setWaterMarkViewSize:(CGSize)waterMarkViewSize {
    _waterMarkViewSize = waterMarkViewSize;
    filter = [[GPUImageBrightnessFilter alloc]init];
    addBlendFilter = [[GPUImageOverlayBlendFilter alloc]init];
    VTWaterMarkView *waterMarkView = [[VTWaterMarkView alloc]initWithFrame:CGRectMake(0, 0, _waterMarkViewSize.width, _waterMarkViewSize.height)];
    waterMarkView.userName = _userName;
    uielement = [[GPUImageUIElement alloc]initWithView:waterMarkView];
    [self addFilter:filter];
    [self addFilter:addBlendFilter];
    [filter addTarget:addBlendFilter];
    [uielement addTarget:addBlendFilter];
//    __unsafe_unretained GPUImageUIElement *weakOverlay = uielement;
    
//    [addBlendFilter disableSecondFrameCheck ];//这样只是在需要更新水印的时候检查更新就不会调用很多次
//
//    runAsynchronouslyOnVideoProcessingQueue(^{
//
//        [weakOverlay update];
//
//    });

    __unsafe_unretained GPUImageUIElement *weakUIE = uielement;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime time) {
        [weakUIE update];
    }];
    [self setInitialFilters:[NSArray arrayWithObjects:filter, nil]];
    [self setTerminalFilter:addBlendFilter];
}
@end
