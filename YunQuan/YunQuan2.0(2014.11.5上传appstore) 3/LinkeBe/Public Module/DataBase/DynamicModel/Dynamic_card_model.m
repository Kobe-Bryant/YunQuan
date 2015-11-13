//
//  Dynamic_card_model.m
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "Dynamic_card_model.h"

@implementation Dynamic_card_model

//筛选不同类型的动态
+(NSArray*) getAllDynamicCardsWithType:(DynamicType) type{
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    NSString* where = nil;
    
    switch (type) {
        case DynamicTypeTogether:
        {
            where = [NSString stringWithFormat:@"type = 8"];
        }
            break;
        case DynamicTypePic:
        {
            where = [NSString stringWithFormat:@"type != 3 and type != 4 and type != 8"];
        }
            break;
        case DynamicTypeHave:
        {
            where = [NSString stringWithFormat:@"type = 3"];
        }
            break;
        case DynamicTypeWant:
        {
            where = [NSString stringWithFormat:@"type = 4"];
        }
            break;
        default:
            break;
    }
    model.where = where;
    model.orderBy = @"createdTime";
    model.orderType = @"desc";
    model.limit = 20;
    
    NSArray* arr = [model getList];
    
    NSMutableArray* cardArr = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary* dic in arr) {
        NSDictionary* conDic = [[dic objectForKey:@"content"] JSONValue];
        //筛选掉被删除的
        if ([[conDic objectForKey:@"delete"] intValue] == 1) {
            continue;
        }
        
        [cardArr addObject:conDic];
    }
    
    [model release];
    
    return cardArr;
}

//获取全部动态
+(NSArray*) getAllDynamicCards{
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    model.orderBy = @"createdTime";
    model.orderType = @"desc";
    model.limit = 20;
    NSArray* arr = [model getList];
    
    [model release];
    
    NSMutableArray* cardArr = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary* dic in arr) {
        NSDictionary* conDic = [[dic objectForKey:@"content"] JSONValue];
        //筛选掉被删除的
        if ([[conDic objectForKey:@"delete"] intValue] == 1) {
            continue;
        }
        
        [cardArr addObject:conDic];
    }
    
    return cardArr;
}

//插入、更新
+(BOOL) insertOrUpdateDynamicCardWithDic:(NSDictionary *)dic{
    int publishId = [[dic objectForKey:@"id"] intValue];
    
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    model.where = [NSString stringWithFormat:@"id = %d",publishId];
    
    BOOL status = YES;
    
    NSDictionary* dbdic = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:publishId],@"id",
                           [dic objectForKey:@"type"],@"type",
                           [dic JSONRepresentation],@"content",
                           [dic objectForKey:@"createdTime"],@"createdTime",
                           [dic objectForKey:@"userId"],@"userId",
                         nil];
    
    if ([model getList].count) {
        //更新
        status = [model updateDB:dbdic];
    }else{
        //插入
        status = [model insertDB:dbdic];
    }
    
    [model release];
    
    return status;
}

//插入、更新content
+(BOOL) insertOrUpdateDynamicCardWithContentDic:(NSDictionary*) dic{
    int publishId = [[dic objectForKey:@"id"] intValue];
    
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    model.where = [NSString stringWithFormat:@"id = %d",publishId];
    
    BOOL status = YES;
    
    NSDictionary* dbdic = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:publishId],@"id",
                           [dic objectForKey:@"type"],@"type",
                           [dic objectForKey:@"content"],@"content",
                           [dic objectForKey:@"createdTime"],@"createdTime",
                           [dic objectForKey:@"userId"],@"userId",
                           nil];
    
    if ([model getList].count) {
        //更新
        status = [model updateDB:dbdic];
    }else{
        //插入
        status = [model insertDB:dbdic];
    }
    
    [model release];
    
    return status;
}

//删除
+(BOOL) deleteDynamicCardWithPublishId:(int) publishId{
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    
    model.where = [NSString stringWithFormat:@"id = %d",publishId];
    BOOL status = [model deleteDBdata];
    
    [model release];
    
    return status;
}

//获取单个动态数据
+(NSDictionary*) getDynamicDataWithPublishId:(int) publishId{
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    
    model.where = [NSString stringWithFormat:@"id = %d",publishId];
    NSArray* arr = [model getList];
    
    [model release];
    
    NSDictionary* dic = nil;
    
    if (arr.count) {
        dic = [[[arr firstObject] objectForKey:@"content"] JSONValue];
    }
    
    return dic;
}

+(long long) getDynamicTsWithPublishId:(int) publishId{
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    
    model.where = [NSString stringWithFormat:@"id = %d",publishId];
    NSArray* arr = [model getList];
    
    [model release];
    
    long long ts = 0;
    if (arr.count) {
        ts = [[[arr firstObject] objectForKey:@"ts"] longLongValue];
    }
    
    return ts;
}

//动态数据只缓存100条
+(void) cacheDynamicCardData{
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    NSArray* allCards = [model getList];
    if (allCards.count > 100) {
        model.limit = 100;
        model.orderBy = @"createdTime";
        model.orderType = @"desc";
        NSArray* saveCards = [model getList];
        
        long long ctime = [[[saveCards lastObject] objectForKey:@"createdTime"] longLongValue];
        model.where = [NSString stringWithFormat:@"createdTime < %lld",ctime];
        model.orderBy = nil;
        model.orderType = nil;
        [model deleteDBdata];
    }
    
}

//删除指定用户的动态数据
+(void) deleteAllDynamicWithUserId:(int) userId{
    Dynamic_card_model* model = [[Dynamic_card_model alloc] init];
    model.where = [NSString stringWithFormat:@"userId = %d",userId];
    [model deleteDBdata];
    
    [model release];
}

@end
