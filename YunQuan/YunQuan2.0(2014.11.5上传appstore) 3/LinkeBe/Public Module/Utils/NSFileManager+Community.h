//
//  NSFileManager+Community.h
//  CommunityAPP
//
//  Created by Stone on 14-3-11.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Community)

/**
 *	@brief	文档目录
 *
 *	@return	返回文档的路径
 */
- (NSString *)applicationDocumentsDirectory;

/**
 *	@brief	库目录
 *
 *	@return	返回库路径
 */
- (NSString *)applicationLibraryDirectory;

/**
 *	@brief	音乐目录
 *
 *	@return	返回音乐目录
 */
- (NSString *)applicationMusicDirectory;

/**
 *	@brief	视频目录
 *
 *	@return	返回视频路径
 */
- (NSString *)applicationMoviesDirectory;

/**
 *	@brief	图片路径
 *
 *	@return	返回图片
 */
- (NSString *)applicationPicturesDirectory;

/**
 *	@brief	临时目录
 *
 *	@return	返回临时目录
 */
- (NSString *)applicationTemporaryDirectory;

/**
 *	@brief	缓存目录
 *
 *	@return	返回缓存
 */
- (NSString *)applicationCachesDirectory;


/**
 *	@brief	本地用户操作目录
 *
 *	@param 	userid 	userid
 *
 *	@return	返回用户本地目录
 */
- (NSString *)communityUserDirectory:(NSString *)userid;


/**
 *	@brief	本地文件转存路径
 *
 *	@return	返回本地文件转存路径 --放在communityUserDirectory 下
 */
- (NSString *)communityLocalDirectory:(NSString *)userid;

/**
 *	@brief	服务器拉下的文件的路径 - 放在communityUserDirectory 下
 *
 *	@return	返回从服务器拉下的文件的路径
 */
- (NSString *)communityCachesDirectory:(NSString *)userid;

/**
 *	@brief	离线收藏的文件路径
 *
 *	@return	返回离线收藏的路径
 */
- (NSString *)communityFavoriteDirectory:(NSString *)userid;


- (NSArray *)subDirectoryOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)erro;

- (NSArray *)filesInDirectory:(NSURL *)directory withExtensions:(NSSet *)fileTypes directoryEnumerationOptions:(NSDirectoryEnumerationOptions)mask errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler;

/**
 *	@brief	文件大小
 *
 *	@param 	path 	路径
 *
 *	@return	file size. If the file not exist, the return value will be 0. If error occurs, the return value will be -1.
 */
- (long long)fileSizeForPath:(NSString *)path;

@end
