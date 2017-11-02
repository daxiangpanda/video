//
//  VTTailWaterMarkFilter.m
//  vtell
//
//  Created by 刘鑫忠 on 2017/10/12.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "VTTailWaterMarkFilter.h"
#import "VTTailView.h"

@implementation VTTailWaterMarkFilter
{
    GPUImageBrightnessFilter *filter ;
    GPUImageBrightnessFilter *blurBlankFilter;
    GPUImageGaussianBlurFilter *blurFilter;
    GPUImageAddBlendFilter *addBlendFilter;
    GPUImageAddBlendFilter *blurBlendFilter;
    GPUImageUIElement *uielement;
    GPUImageUIElement *waterMarkUIElement;
}

- (id)init
{
    if(!(self = [super init]))
    {
        return nil;
    }
    return self;
}

- (id)initWithLastFrameImage:(UIImage*)lastFrameImage userName:(NSString *)userName {
    return nil;
}

- (void)setLastFrameImage:(UIImage *)lastFrameImage userName:(NSString *)userName {
    filter = [[GPUImageBrightnessFilter alloc]init];
    blurFilter = [[GPUImageGaussianBlurFilter alloc]init];
    blurBlankFilter = [[GPUImageBrightnessFilter alloc]init];
    [blurFilter setBlurRadiusInPixels:0.0f];
    addBlendFilter = [[GPUImageAddBlendFilter alloc]init];
//    [addBlendFilter disableSecondFrameCheck ];
    blurBlendFilter = [[GPUImageAddBlendFilter alloc]init];
//    [blurBlendFilter disableSecondFrameCheck ];

    uielement = [[GPUImageUIElement alloc]initWithView:[[UIImageView alloc]initWithImage:lastFrameImage]];
    CGSize tailViewSize = lastFrameImage.size;
    VTTailView *tailView = [[VTTailView alloc]initWithFrame:CGRectMake(0, 0, tailViewSize.width, tailViewSize.height)];
    tailView.alpha = 0;
    tailView.userName = userName;

    waterMarkUIElement = [[GPUImageUIElement alloc]initWithView:tailView];
    [self addFilter:filter];
    [self addFilter:addBlendFilter];
    [self addFilter:blurBlankFilter];
    [self addFilter:blurFilter];
    [self addFilter:blurBlendFilter];
    
    [filter addTarget:addBlendFilter];
    [addBlendFilter addTarget:blurFilter];
    [blurFilter addTarget:blurBlankFilter];
    [blurBlankFilter addTarget:blurBlendFilter];
    
    [uielement addTarget:addBlendFilter];
    [waterMarkUIElement addTarget:blurBlendFilter];
    
    [self setInitialFilters:[NSArray arrayWithObjects:filter, nil]];
    [self setTerminalFilter:blurBlendFilter];
    __unsafe_unretained GPUImageUIElement *weakUIE = uielement;
    __unsafe_unretained GPUImageUIElement *weakUIEw = waterMarkUIElement;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime time) {
//        [waterMarkUIElement update];
        [uielement update];
    }];

    CGFloat tailVideoTime = 1.50f;

    [blurBlankFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime time) {
//        if(round(((CGFloat)time.value)/time.timescale/tailVideoTime*6) != blurFilter.blurRadiusInPixels){
//            dispatch_sync(dispatch_get_main_queue(), ^{
                //Update UI in UI thread here
//                ((UILabel*)[tailView userNameLabel]).text = [NSString stringWithFormat:@"导演•%@",userName];
                [tailView setAlpha:((CGFloat)time.value)/time.timescale/tailVideoTime];
//            });
            [blurFilter setBlurRadiusInPixels:((CGFloat)time.value)/time.timescale/tailVideoTime * 6];
            [uielement update];
//            [waterMarkUIElement update];
//        }
    }];
    
}


@end
