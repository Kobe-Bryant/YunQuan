//
//  SnailCacheManager.m
//  QlVoiceMutified
//
//  Created by LazySnail on 14-6-25.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "SnailCacheManager.h"
#import "NSString+MD5.h"
#import "ChatMacro.h"

static NSTimeInterval cacheTime =  (double)999999;

@implementation SnailCacheManager

+ (NSData *)getAndCacheDataFromUrlStr:(NSString *)urlStr complation:(ComplationBlock) compation
{
    __block NSData * voiceData = nil;
    voiceData = [SnailCacheManager objectForKey:urlStr];
    if (voiceData == nil) {
        NSURL * fileUrl = [NSURL URLWithString:urlStr];
        voiceData = [[NSData dataWithContentsOfURL:fileUrl]retain];
        if (voiceData == nil) {
        }
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [SnailCacheManager setObject:voiceData forKey:urlStr complation:compation];
        });
        return voiceData;
    } else {
        return voiceData;
    }
}


+ (void) resetCache:(NSString *)cacheName {
	[[NSFileManager defaultManager] removeItemAtPath:[SnailCacheManager cacheDirectoryWithFileName:cacheName] error:nil];
}

+ (NSData*) objectForKey:(NSString*)key {
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * keyHashStr = [self hashKeyStrWithKey:key];
	NSString *filename = [[self cacheDirectoryWithFileName:VoiceFilePath] stringByAppendingPathComponent:keyHashStr];
	BOOL isExist = [fileManager fileExistsAtPath:filename];
    
	if (isExist)
	{
		NSDate *modificationDate = [[fileManager attributesOfItemAtPath:filename error:nil] objectForKey:NSFileModificationDate];
		if ([modificationDate timeIntervalSinceNow] > cacheTime) {
			[fileManager removeItemAtPath:filename error:nil];
		} else {
			NSData *data = [NSData dataWithContentsOfFile:filename];
			return data;
		}
	}
	return nil;
}

+ (void)removeObjectForKey:(NSString *)key
{
    NSString * fileName = [SnailCacheManager fileNameForKey:key];
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:fileName error:nil];
}

+ (NSString *)fileNameForKey:(NSString *)key
{
    NSString * keyHash = [self hashKeyStrWithKey:key];
    NSString *filename = [[self cacheDirectoryWithFileName:VoiceFilePath] stringByAppendingPathComponent:keyHash];
    return filename;
}

+ (void) setObject:(NSData*)data forKey:(NSString*)key complation:(ComplationBlock) complation {
	
    NSString * keyHash = [self hashKeyStrWithKey:key];
    NSString *filename = [[self cacheDirectoryWithFileName:VoiceFilePath] stringByAppendingPathComponent:keyHash];
    NSError *error;

    __block NSData * voiceData = data;
    [self getOrCreateFiledWithPathKind:VoiceFilePath];
	@try {
		[data writeToFile:filename options:NSDataWritingAtomic error:&error];
        
        if (error) {
            if (voiceData != nil && complation != nil) {
                complation(voiceData);
            }
//            NSLog(@"%@",error);
        } else {
            if (complation != nil && voiceData != nil) {
                complation(voiceData);
            }
        }
	}
	@catch (NSException * e) {
		[Common checkProgressHUD:@"下载语音异常" andImage:nil showInView:APPKEYWINDOW];
	}
}

+ (NSString *)getOrCreateFiledWithPathKind:(NSString *)path
{
    NSString * filePath = [self cacheDirectoryWithFileName:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL isDir = YES;
    
	if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
		[fileManager createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
	}
    if (error) {
        NSLog(@"Create Path %@ faild %@",filePath,error);
    }
    return filePath;
}

+ (NSString*) cacheDirectoryWithFileName:(NSString *)fileName {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [paths objectAtIndex:0];
	cacheDirectory = [cacheDirectory stringByAppendingPathComponent:fileName];
    
	return cacheDirectory;
}

+ (NSString *)getVoiceCachePathForKey:(NSString *)key
{
    NSString * cachePathStr = [self cacheDirectoryWithFileName:VoiceFilePath];
    cachePathStr = [cachePathStr stringByAppendingPathComponent:[self hashKeyStrWithKey:key]];
    return cachePathStr;
}

+ (NSString *)hashKeyStrWithKey:(NSString *)key
{
    NSString * hashKey = [[key MD5Hash]stringByAppendingString:VoiceFormatSuffix];
    return hashKey;
}

@end
