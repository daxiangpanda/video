//
//  VTFileManager+FileName.h
//  vtell
//
//  Created by 孙旭让 on 2017/8/4.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "VTFileManager.h"

@interface VTFileManager (FileName)

- (NSString *)fileNameByCurrentTimeIntervalWithFileType:(NSString *)type;

@end
