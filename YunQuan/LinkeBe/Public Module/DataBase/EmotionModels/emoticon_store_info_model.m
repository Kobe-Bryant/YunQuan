//
//  emotion_store_info_model.m
//  ql
//
//  Created by LazySnail on 14-8-27.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "emoticon_store_info_model.h"

@implementation emoticon_store_info_model

+ (BOOL)insertDataWithDic:(NSDictionary *)dic
{
    BOOL successJudger = NO;
    emoticon_store_info_model * model = [[emoticon_store_info_model alloc]init];
    successJudger = [model insertDB:dic];
    RELEASE_SAFE(model);
    return successJudger;
}

+ (NSDictionary *)getLatestData
{
    emoticon_store_info_model * geter = [[emoticon_store_info_model alloc]init];
    geter.where = [NSString stringWithFormat:@"1 order by ts desc"];
    NSMutableArray * listArr = [geter getList];
    NSDictionary * resultDic = [listArr firstObject];
    RELEASE_SAFE(geter);
    return resultDic;
}

+ (BOOL)deleteAllData{
    emoticon_store_info_model *model = [[emoticon_store_info_model alloc]init];
    return [db_model deleteAllDataWithModel:model];
}

@end
