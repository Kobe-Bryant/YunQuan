//
//  emoticon_item_list_model.m
//  ql
//
//  Created by LazySnail on 14-8-27.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "emoticon_item_list_model.h"

@implementation emoticon_item_list_model

+ (BOOL)insertOrUpdateItemWithDic:(NSDictionary *)dic
{
    long long itemID = [[dic objectForKey:@"id"]longLongValue];
    emoticon_item_list_model * model = [[emoticon_item_list_model alloc]init];
    model.where = [NSString stringWithFormat:@"id = %lld",itemID];
    return [db_model updateDataWithModel:model withDic:dic];
}

+ (BOOL)deleteItemWithItemID:(long long)itemID
{
    emoticon_item_list_model * model = [[emoticon_item_list_model alloc]init];
    model.where = [NSString stringWithFormat:@"id = %lld",itemID];
    return [db_model deleteAllDataWithModel:model];
}

+ (BOOL)deleteAllItemWithemoticonID:(long long)emoticonID
{
    emoticon_item_list_model *model = [[emoticon_item_list_model alloc]init];
    model.where = [NSString stringWithFormat:@"emoticon_id = %lld",emoticonID];
    return [db_model deleteAllDataWithModel:model];
}

+ (BOOL)deleteAllData
{
    emoticon_item_list_model * model = [[emoticon_item_list_model alloc]init];
    return [db_model deleteAllDataWithModel:model];
}

+ (NSDictionary *)getItemDicWithItemID:(long long)itemID
{
    emoticon_item_list_model *model = [[emoticon_item_list_model alloc]init];
    model.where = [NSString stringWithFormat:@"id = %lld",itemID];
    NSMutableArray * emoticonArr = [model getList];
    NSDictionary * resultDic = nil;
    if (emoticonArr.count > 0) {
        resultDic = [emoticonArr firstObject];
    }
    RELEASE_SAFE(model);
    return resultDic;
}

+ (NSMutableArray *)getAllItemWithEmoticonID:(long long)emoticonID
{
    emoticon_item_list_model *model = [[emoticon_item_list_model alloc]init];
    model.where = [NSString stringWithFormat:@"packetId = %lld",emoticonID];
    NSMutableArray *emoticonArr = [model getList];
    RELEASE_SAFE(model);
    return emoticonArr;
}


@end
