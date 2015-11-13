//
//  emotion_store_info_model.h
//  ql
//
//  Created by LazySnail on 14-8-27.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "db_model.h"

@interface emoticon_store_info_model : db_model

+ (BOOL)insertDataWithDic:(NSDictionary *)dic;

+ (NSDictionary *)getLatestData;

+ (BOOL)deleteAllData;

@end
