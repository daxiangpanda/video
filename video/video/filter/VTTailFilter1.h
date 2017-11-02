//
//  VTTailFilter1.h
//  vtell
//
//  Created by 刘鑫忠 on 2017/10/16.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "GPUImage.h"

@interface VTTailFilter1 : GPUImageFilterGroup

@property (nonatomic, strong) UIImage* image;
- (void)setLastFrameImage:(UIImage *)lastFrameImage userName:(NSString *)userName;
@end
