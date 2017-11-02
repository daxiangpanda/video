//
//  VTMidWaterMarkFilter.h
//  vtell
//
//  Created by 刘鑫忠 on 2017/10/12.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "GPUImage.h"

@interface VTMidWaterMarkFilter : GPUImageFilterGroup

@property (nonatomic, copy)   NSString     *userName;
@property (nonatomic, assign) CGSize       waterMarkViewSize;

@end
