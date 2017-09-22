//
//  VTFileManager.m
//  vtell
//
//  Created by 孙旭让 on 2017/8/4.
//  Copyright © 2017年 sohu. All rights reserved.
//

#import "VTFileManager.h"
#include <sys/xattr.h>

NSString * const kVTExpireDatesKey = @"VTManager.expireDates";
static NSLock *gVTSyncToUserDefaultsLock = nil;

@implementation VTFileManager

+(VTFileManager *)shareCacheFileInstance{
    static VTFileManager *cacheFileInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [cachePaths objectAtIndex:0];
        cacheFileInstance = [[VTFileManager alloc] initWithBaseFilePath:cachePath];
    });
    return cacheFileInstance;
}

+(VTFileManager *)shareOfflineFileInstance{
    static VTFileManager *offlineInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *offlinePath = [[libraryPaths objectAtIndex:0] stringByAppendingPathComponent:@"Offline"];
        offlineInstance = [[VTFileManager alloc] initWithBaseFilePath:offlinePath];
    });
    return offlineInstance;
}

+(VTFileManager *)shareTmpFileInstance{
    static VTFileManager *tmpFileInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        tmpFileInstance = [[VTFileManager alloc] initWithBaseFilePath:tmpPath];
    });
    return tmpFileInstance;
}

#pragma mark - init

-(id)initWithBaseFilePath:(NSString *)basePath{
    self = [super init];
    if (self) {
        _baseFilePath = basePath;
        [[NSFileManager defaultManager] createDirectoryAtPath:_baseFilePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:_baseFilePath]];
        _expireDateDictionary = [[[[NSUserDefaults standardUserDefaults] objectForKey:kVTExpireDatesKey] objectForKey:self.baseFilePath] mutableCopy];
        if (!_expireDateDictionary) {
            _expireDateDictionary = [NSMutableDictionary dictionary];
        }
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            gVTSyncToUserDefaultsLock = [[NSLock alloc] init];
        });
    }
    return self;
}


#pragma mark - directory manager
- (NSString *)parseDirectoryAtPath:(NSString *)path{
    return [self absolutePathWithPath:path];
}

-(NSString *)parseParentDirectoryAtPath:(NSString *)path{
    NSString *parentDirPath = [self absolutePathWithPath:path];
    NSMutableArray *pathArray = [NSMutableArray arrayWithArray:[parentDirPath componentsSeparatedByString:@"/"]];
    if ([pathArray count] > 1) {
        [pathArray removeLastObject];
        NSString *parentDirPath = [pathArray componentsJoinedByString:@"/"];
        return parentDirPath;
    } else {
        return nil;
    }
}

-(BOOL)createParentDirectoriesAtPath:(NSString *)path{
    return [[NSFileManager defaultManager] createDirectoryAtPath:[self parseParentDirectoryAtPath:path]
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:NULL];
}

- (NSString *)createDirectoriesAtPath:(NSString *)path{
    NSString *absolutePath = [self absolutePathWithPath:path];
    BOOL res = [[NSFileManager defaultManager] createDirectoryAtPath:absolutePath
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:NULL];
    if (res == YES) {
        return  absolutePath;
    }else{
        return nil;
    }
}


-(BOOL)parentDirectoriesExistAtPath:(NSString *)path{
    NSString *parentDirPath = [self parseParentDirectoryAtPath:path];
    return [[NSFileManager defaultManager] fileExistsAtPath:parentDirPath];
}


#pragma mark - Write File
-(BOOL)writeData:(NSData *)data atPath:(NSString *)path{
    return [self writeData:data atPath:path expire:0];
}

-(BOOL)writeString:(NSString *)string atPath:(NSString *)path{
    return [self writeString:string atPath:path expire:0];
}

-(BOOL)writeDictionary:(NSDictionary *)dictionary atPath:(NSString *)path{
    return [self writeDictionary:dictionary atPath:path expire:0];
}

- (BOOL) writeArray:(NSArray *)array atPath:(NSString *)path{
    return [self writeArray:array atPath:path expire:0];
}

-(BOOL)writeData:(NSData *)data atPath:(NSString *)path expire:(NSTimeInterval)expire{
    if (![self parentDirectoriesExistAtPath:path]) {
        [self createParentDirectoriesAtPath:path];
    }
    
    NSString *finalPath = [self absolutePathWithPath:path];
    
    [self setExpireTimeInterval:expire forFilePath:path];
    
    return [data writeToFile:finalPath atomically:YES];
}

-(BOOL)writeDictionary:(NSDictionary *)dictionary atPath:(NSString *)path expire:(NSTimeInterval)expire{
    if (![self parentDirectoriesExistAtPath:path]) {
        [self createParentDirectoriesAtPath:path];
    }
    
    NSString *finalPath = [self absolutePathWithPath:path];
    
    [self setExpireTimeInterval:expire forFilePath:path];
    
    return [dictionary writeToFile:finalPath atomically:YES];
}

-(BOOL)writeString:(NSString *)string atPath:(NSString *)path expire:(NSTimeInterval)expire {
    if (![self parentDirectoriesExistAtPath:path]) {
        [self createParentDirectoriesAtPath:path];
    }
    
    NSString *finalPath = [self absolutePathWithPath:path];
    
    [self setExpireTimeInterval:expire forFilePath:path];
    
    return [string writeToFile:finalPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (BOOL) writeArray:(NSArray *)array atPath:(NSString *)path expire:(NSTimeInterval)expire{
    if (![self parentDirectoriesExistAtPath:path]) {
        [self createParentDirectoriesAtPath:path];
    }
    
    NSString *finalPath = [self absolutePathWithPath:path];
    
    [self setExpireTimeInterval:expire forFilePath:path];
    
    return [array writeToFile:finalPath atomically:YES];
}


#pragma mark - Delete
-(BOOL)deleteFileAtPath:(NSString *)path{
    NSString *finalPath = [self absolutePathWithPath:path];
    
    [gVTSyncToUserDefaultsLock lock];
    
    [_expireDateDictionary removeObjectForKey:path];
    [self _syncExpiredTimeToUserDefaults];
    
    [gVTSyncToUserDefaultsLock unlock];
    
    return [[NSFileManager defaultManager] removeItemAtPath:finalPath error:NULL];
}

- (NSArray *)fileNamesInParentDirectory:(NSString *)path{
    NSString *directoryPath = [self absolutePathWithPath:path];
    NSString* filePath;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    NSMutableArray *fileNames = [NSMutableArray array];
    while (filePath = [enumerator nextObject])
    {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/%@",directoryPath,filePath]
                                                 isDirectory: &isDirectory]) {
            if (!isDirectory)
            {
                [fileNames addObject:[filePath lastPathComponent]];
            }
        }
    }
    return fileNames;
}

- (NSArray *)filePathInParentDirectory:(NSString *)path{
    NSString *directoryPath = [self absolutePathWithPath:path];
    NSString* filePath;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    NSMutableArray *fileNames = [NSMutableArray array];
    while (filePath = [enumerator nextObject])
    {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/%@",directoryPath,filePath]
                                                 isDirectory: &isDirectory]) {
            if (!isDirectory)
            {
                [fileNames addObject:[NSString stringWithFormat:@"%@/%@",directoryPath,[filePath lastPathComponent]]];
            }
        }
    }
    return fileNames;
}



#pragma mark - Read Files
- (NSString *) readStringAtPath:(NSString *)path{
    NSString *finalPath = [self absolutePathWithPath:path];
    if (!finalPath ||
        ![self fileVaildAtFilePath:path]) {
        return nil;
    }
    return [NSString stringWithContentsOfFile:finalPath encoding:NSUTF8StringEncoding error:NULL];
}

- (NSDictionary *) readDictionaryAtPath:(NSString *)path{
    NSString *finalPath = [self absolutePathWithPath:path];
    if (!finalPath ||
        ![self fileVaildAtFilePath:path]) {
        return nil;
    }
    return [NSDictionary dictionaryWithContentsOfFile:finalPath];
}

- (NSData *) readDataAtPath:(NSString *)path{
    NSString *finalPath = [self absolutePathWithPath:path];
    if (!finalPath ||
        ![self fileVaildAtFilePath:path]) {
        return nil;
    }
    return [NSData dataWithContentsOfFile:finalPath];
}

- (NSArray *)readArrayAtPath:(NSString *)path{
    NSString *finalPath = [self absolutePathWithPath:path];
    if (!finalPath ||
        ![self fileVaildAtFilePath:path]) {
        return nil;
    }
    return [NSArray arrayWithContentsOfFile:finalPath];
}


#pragma mark - expire
- (void) setExpireTimeInterval:(NSTimeInterval)expireTimeInterval forFilePath:(NSString *)filePath{
    [gVTSyncToUserDefaultsLock lock];
    
    NSDate *expireDate = (expireTimeInterval > 0) ? [NSDate dateWithTimeIntervalSinceNow:expireTimeInterval] : [NSDate distantFuture];
    [_expireDateDictionary setObject:expireDate forKey:filePath];
    [self _syncExpiredTimeToUserDefaults];
    
    [gVTSyncToUserDefaultsLock unlock];
}

- (BOOL) cleanExpireFile{
    NSArray *allFilePathArray = [NSArray arrayWithArray:_expireDateDictionary.allKeys];
    for (NSString *fileKeyPath in allFilePathArray) {
        if (![self fileVaildAtFilePath:fileKeyPath]) {
            if (![self deleteFileAtPath:fileKeyPath]) {
                return NO;
            }
        }
    }
    return YES;
}


#pragma mark - File Vaild
- (BOOL) fileExpiredAtFilePath:(NSString *)filePath{
    NSDate *expiredDate = [_expireDateDictionary objectForKey:filePath];
    if (!expiredDate ||
        [expiredDate timeIntervalSinceNow] >= 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) fileExistsAtFilePath:(NSString *)filePath{
    if(![filePath hasPrefix:@"/var/"]){
        filePath = [self absolutePathWithPath:filePath];
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (BOOL) fileVaildAtFilePath:(NSString *)filePath{
    if ([self fileExistsAtFilePath:filePath] &&
        ![self fileExpiredAtFilePath:filePath]) {
        return YES;
    }
    return NO;
}


#pragma mark - util
- (NSString *) absolutePathWithPath:(NSString *)path{
    NSString *finalPath = [self.baseFilePath stringByAppendingPathComponent:path];
    return finalPath;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_1) {
        return [URL setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:nil];
    } else {
        u_int8_t attrValue = 1;
        return setxattr([[URL path] fileSystemRepresentation], "com.apple.MobileBackup",
                        &attrValue, sizeof(attrValue), 0, 0) == 0;
    }
}

- (void)_syncExpiredTimeToUserDefaults{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [[userDefaults objectForKey:kVTExpireDatesKey] mutableCopy];
    if (dictionary == nil) dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setObject:[NSDictionary dictionaryWithDictionary:_expireDateDictionary]
                   forKey:self.baseFilePath];
    [userDefaults setObject:[NSDictionary dictionaryWithDictionary:dictionary]
                     forKey:kVTExpireDatesKey];
    [userDefaults synchronize];
}

@end
