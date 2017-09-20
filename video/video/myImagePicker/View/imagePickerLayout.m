//
//  imagePickerLayout.m
//  video
//
//  Created by 刘鑫忠 on 2017/9/20.
//  Copyright © 2017年 刘鑫忠. All rights reserved.
//

#import "imagePickerLayout.h"
@interface imagePickerLayout()

@property (nonatomic, strong) NSMutableArray    *columnMaxYs;
@property (nonatomic, strong) NSMutableArray    *attrsArray;
@property (nonatomic, assign) NSInteger         defaultColumsCount;

@end

@implementation imagePickerLayout

#pragma mark - life Cycle
-(instancetype)initWithColumsCount:(NSInteger)count{
    self = [super init];
    if (self) {
        _defaultColumsCount = count;
        if (count == 0) {
            _defaultColumsCount = 2;
        }
    }
    return self;
}

@end
