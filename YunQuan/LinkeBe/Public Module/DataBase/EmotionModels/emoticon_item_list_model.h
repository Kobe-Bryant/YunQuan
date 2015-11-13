//
//  emotion_item_list_model.h
//  ql
//
//  Created by LazySnail on 14-8-27.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "db_model.h"

@interface emoticon_item_list_model : db_model

+ (BOOL)insertOrUpdateItemWithDic:(NSDictionary *)dic;

+ (BOOL)deleteItemWithItemID:(long long)itemID;

+ (BOOL)deleteAllItemWithEmoticonID:(long long)emoticonID;

+ (BOOL)deleteAllData;

+ (NSDictionary *)getItemDicWithItemID:(long long)itemID;

+ (NSMutableArray *)getAllItemWithEmoticonID:(long long)emoticonID;


@end
