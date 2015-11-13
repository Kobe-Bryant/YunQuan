//
//  NSObject+Time.h
//  CommunityAPP
//
//  Created by Stone on 14-3-21.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Time)

//获取当前时间
+(NSString *) getCurrentTime;

//字符串格式时间转成NSDate yyyy-mm-dd HH:mm:ss
+(NSDate *)fromatterDateFromStr:(NSString *)time;

//字符串格式时间转成字符串 yyyy-mm-dd HH:mm:ss
+ (NSString *)formatterDate:(NSString *)time;

/**
 
 * 计算指定时间与当前的时间差
 
 * @param compareDate   某一指定时间
 
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 
 */
+(NSString *) compareCurrentTime:(NSDate*) compareDate;

@end
