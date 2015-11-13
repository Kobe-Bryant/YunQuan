//
//  SnailCacheManager.h
//  QlVoiceMutified
//
//  Created by LazySnail on 14-6-25.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VoiceFilePath @"VoicieSnailCache"
#define VoiceFormatSuffix @".amr"

typedef void (^ ComplationBlock) (NSData * voiceData);

@interface SnailCacheManager : NSObject

//获取并缓存文件
+ (NSData *)getAndCacheDataFromUrlStr:(NSString *)urlStr complation:(ComplationBlock) compation;

//以指定的Key缓存文件
+ (void) setObject:(NSData*)data forKey:(NSString*)key complation:(ComplationBlock) complation;

//移除指定key 文件
+ (void)removeObjectForKey:(NSString *)key;

//清空缓存
+ (void) resetCache:(NSString *)cacheName;

//获取自定Key的缓存文件
+ (NSData*) objectForKey:(NSString*)key;

//获取指定类型的缓存 **文件夹** 路径
+ (NSString *)getOrCreateFiledWithPathKind:(NSString *)path;

//获取指定Key的文件路径
+ (NSString *)getVoiceCachePathForKey:(NSString *)key;

//缓存路径
+ (NSString*) cacheDirectoryWithFileName:(NSString *)fileName;

@end
