//
//  VTFileManager+FileName.m
//  vtell
//
//  Created by 孙旭让 on 2017/8/4.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "VTFileManager+FileName.h"

@implementation VTFileManager (FileName)

- (NSString *)fileNameByCurrentTimeIntervalWithFileType:(NSString *)type{
    long  interval = ceil([[NSDate date] timeIntervalSince1970] * 1000000);
    
    NSString *dateString = [NSString stringWithFormat:@"%ld.",interval];

    if ([type length] == 0) {
        return dateString;
    }
    
    return [dateString stringByAppendingString:type];
}

@end
