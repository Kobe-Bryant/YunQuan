//
//  emoticon_detail_info_model.m
//  ql
//
//  Created by LazySnail on 14-8-27.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "emoticon_detail_info_model.h"

@implementation emoticon_detail_info_model

+ (BOOL)insertEmoticonDetailInfoWithDic:(NSDictionary *)dic
{
    BOOL successJudger = NO;
    emoticon_detail_info_model * model = [[emoticon_detail_info_model alloc]init];
    successJudger = [model insertDB:dic];
    RELEASE_SAFE(model);
    return successJudger;
}

+ (BOOL)deleteAllData
{
    emoticon_detail_info_model * model = [[emoticon_detail_info_model alloc]init];
    return [db_model deleteAllDataWithModel:model];
}

+ (NSDictionary *)getLatestDetailInfoDic
{
    emoticon_detail_info_model *model = [[emoticon_detail_info_model alloc]init];
    model.where = [NSString stringWithFormat:@"1 order by ts desc"];
    NSMutableArray * infoArr = [model getList];
    NSDictionary * resultDic = nil;
    if (infoArr.count >0) {
        resultDic = [infoArr firstObject];
    }
    
    RELEASE_SAFE(model);
    return resultDic;
}

@end
