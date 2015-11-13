//
//  NSString+MessageDataExtension.h
//  ql
//
//  Created by LazySnail on 14-5-16.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OriginData.h"

@interface NSString (MessageDataExtension)

// 通过一堆消息对象来生成消息对象存储的JSON字符串
+ (NSString *)getStrWithMessageDatas:(OriginData *)orgData, ...;

@end
