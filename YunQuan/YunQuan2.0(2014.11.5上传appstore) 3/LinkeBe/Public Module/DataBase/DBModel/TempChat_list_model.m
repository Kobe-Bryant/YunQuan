//
//  TempChat_list_model.m
//  LinkeBe
//
//  Created by Dream on 14-10-8.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "TempChat_list_model.h"
#import "SBJson.h"

@implementation TempChat_list_model

+ (BOOL)insertOrUpdateTempChatListWithDic:(NSDictionary *)dic
{
    NSMutableDictionary * mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSArray *membersArr = [mutDic objectForKey:@"members"];
    [mutDic removeObjectForKey:@"members"];
    NSString * membersJsonStr = [membersArr JSONRepresentation];
    
    [mutDic setObject:membersJsonStr forKey:@"members"];
    
    TempChat_list_model * operator = [[TempChat_list_model alloc]init];
    operator.where = [NSString stringWithFormat:@"id = %lld",[[dic objectForKey:@"id"] longLongValue]];
    return [db_model updateDataWithModel:operator withDic:mutDic];
}


+ (NSDictionary *)getTempChatContentDataWith:(long long)circleId
{
    TempChat_list_model * geter = [[TempChat_list_model alloc]init];
    geter.where = [NSString stringWithFormat:@"id = %lld",circleId];
    NSArray * list = [geter getList];
    NSDictionary * resultDic = nil;
    NSMutableDictionary *dic = nil;
    RELEASE_SAFE(geter);

    if (list.count > 0) {
        resultDic = [list firstObject];
    }
    if (resultDic != nil) {
        dic = [NSMutableDictionary dictionaryWithDictionary:resultDic];
        NSString * memberJSon = [dic objectForKey:@"members"];
        NSArray * memebrArr = [memberJSon JSONValue];
        [dic removeObjectForKey:@"members"];
        [dic setObject:memebrArr forKey:@"members"];
    }
    
    return dic;
}

+ (BOOL)deleteDataWithTempCircleID:(long long)circleID
{
    BOOL judger = NO;
    TempChat_list_model * geter = [[TempChat_list_model alloc]init];
    geter.where = [NSString stringWithFormat:@"id = %lld",circleID];
    judger = [geter deleteDBdata];
    RELEASE_SAFE(geter);
    return judger;
}

@end
