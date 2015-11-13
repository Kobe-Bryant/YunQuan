//
//  Dynamic_card_model.h
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"

#import "DynamicCommon.h"

@interface Dynamic_card_model : db_model

//筛选不同类型的动态
+(NSArray*) getAllDynamicCardsWithType:(DynamicType) type;

//获取全部动态
+(NSArray*) getAllDynamicCards;

//插入、更新
+(BOOL) insertOrUpdateDynamicCardWithDic:(NSDictionary*) dic;

//插入、更新content
+(BOOL) insertOrUpdateDynamicCardWithContentDic:(NSDictionary*) dic;

//删除
+(BOOL) deleteDynamicCardWithPublishId:(int) publishId;

//获取单个动态数据
+(NSDictionary*) getDynamicDataWithPublishId:(int) publishId;

//获取某条动态的时间戳
+(long long) getDynamicTsWithPublishId:(int) publishId;

//动态数据只缓存100条
+(void) cacheDynamicCardData;

//删除指定用户的动态数据
+(void) deleteAllDynamicWithUserId:(int) userId;

@end
