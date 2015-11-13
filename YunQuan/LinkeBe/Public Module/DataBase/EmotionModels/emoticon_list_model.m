//
//  emotion_list_model.m
//  ql
//
//  Created by LazySnail on 14-8-27.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "emoticon_list_model.h"

@implementation emoticon_list_model

+ (BOOL)insertOrUpdateListWithDic:(NSDictionary *)dic
{
    long long emotionID = [[dic objectForKey:@"packetId"]longLongValue];
    emoticon_list_model * geter = [[emoticon_list_model alloc]init];
    geter.where = [NSString stringWithFormat:@"packetId = %lld",emotionID];
    return [db_model updateDataWithModel:geter withDic:dic];
}

+ (BOOL)deleteListWithEmoticonID:(long long)emotionID
{
    emoticon_list_model * geter = [[emoticon_list_model alloc]init];
    geter.where = [NSString stringWithFormat:@"packetId = %lld",emotionID];
    return [db_model deleteAllDataWithModel:geter];
}

+ (BOOL)deleteAllData
{
    emoticon_list_model *model = [[emoticon_list_model alloc]init];
    return [db_model deleteAllDataWithModel:model];
}

+ (NSDictionary *)getEmoticonDicWithEmoticonID:(long long)emotionID
{
    emoticon_list_model * geter = [[emoticon_list_model alloc]init];
    geter.where = [NSString stringWithFormat:@"packetId = %lld",emotionID];
    NSMutableArray * list = [geter getList];
    NSDictionary * resultDic = nil;
    if (list.count > 0) {
        resultDic = [list firstObject];
    }
    RELEASE_SAFE(geter);
    return resultDic;
}

+ (NSMutableArray *)getAllEmoticons
{
    emoticon_list_model * geter = [[emoticon_list_model alloc]init];
    NSMutableArray * resultArr = [geter getList];
    RELEASE_SAFE(geter);
    return resultArr;
}

+ (NSMutableArray *)getDownloadedEmoticons
{
    emoticon_list_model * geter = [[emoticon_list_model alloc]init];
    geter.where = [NSString stringWithFormat:@"status = 1"];
    NSMutableArray * resultArr = [geter getList];
    RELEASE_SAFE(geter);
    return resultArr;
}

@end
