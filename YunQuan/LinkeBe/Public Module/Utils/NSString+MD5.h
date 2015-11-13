//
//  NSString+MD5.h
//  CommunityAPP
//
//  Created by Stone on 14-3-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

/**
 *	@brief	MD5加密（小写）
 *
 *	@return	返回小写的加密串
 */
- (NSString *)md5;


/**
 *	@brief	MD5加密（大写）
 *
 *	@return	返回大写的加密串
 */
- (NSString *)uppercaseMd5;

@end
