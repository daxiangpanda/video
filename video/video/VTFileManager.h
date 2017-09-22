//
//  VTFileManager.h
//  vtell
//
//  Created by 孙旭让 on 2017/8/4.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTFileManager : NSObject{
    NSMutableDictionary *_expireDateDictionary;
}

@property (nonatomic, copy, readonly) NSString *baseFilePath;

+ (VTFileManager *)shareCacheFileInstance;
+ (VTFileManager *)shareTmpFileInstance;
+ (VTFileManager *)shareOfflineFileInstance;

// 返回时文件的绝对路径
- (NSString *)createDirectoriesAtPath:(NSString *)path;
- (BOOL)createParentDirectoriesAtPath:(NSString *)path;

//删除路径
- (BOOL)deleteFileAtPath:(NSString *)path;

//获取
- (BOOL)parentDirectoriesExistAtPath:(NSString *)path;

//获取父文件夹
- (NSString *)parseDirectoryAtPath:(NSString *)path;
- (NSString *)parseParentDirectoryAtPath:(NSString *)path;

//路径下所有文件名称
- (NSArray *)fileNamesInParentDirectory:(NSString *)path;
- (NSArray *)filePathInParentDirectory:(NSString *)path;


//写入字符串
- (BOOL)writeString:(NSString *)string atPath:(NSString *)path;
- (BOOL)writeString:(NSString *)string atPath:(NSString *)path expire:(NSTimeInterval)expire;

//写入二进制
- (BOOL)writeData:(NSData *)data atPath:(NSString *)path;
- (BOOL)writeData:(NSData *)data atPath:(NSString *)path expire:(NSTimeInterval)expire;

//写入字典
- (BOOL)writeDictionary:(NSDictionary *)dictionary atPath:(NSString *)path;
- (BOOL)writeDictionary:(NSDictionary *)dictionary atPath:(NSString *)path expire:(NSTimeInterval)expire;

//写入数组
- (BOOL)writeArray:(NSArray *)array atPath:(NSString *)path;
- (BOOL)writeArray:(NSArray *)array atPath:(NSString *)path expire:(NSTimeInterval)expire;

// 从本地读取字符串
- (NSString *)readStringAtPath:(NSString *)path;

// 从本地读取字典
- (NSDictionary *)readDictionaryAtPath:(NSString *)path;

// 从本地读取二进制
- (NSData *)readDataAtPath:(NSString *)path;

// 从本地读取数组
- (NSArray *)readArrayAtPath:(NSString *)path;

// 设置过期时间
- (void)setExpireTimeInterval:(NSTimeInterval)expireTimeInterval forFilePath:(NSString *)filePath;

//清除失效的文件夹
- (BOOL)cleanExpireFile;

//判断是否失效
- (BOOL)fileExpiredAtFilePath:(NSString *)filePath;

//判断是否存在
- (BOOL)fileExistsAtFilePath:(NSString *)filePath;
//+ (BOOL)fileExistsAtFilePath:(NSString *)filePath;


//判断是否可用
- (BOOL)fileVaildAtFilePath:(NSString *)filePath;

@end
