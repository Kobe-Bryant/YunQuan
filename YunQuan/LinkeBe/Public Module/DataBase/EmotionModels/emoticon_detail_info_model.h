//
//  emoticon_detail_info_model.h
//  ql
//
//  Created by LazySnail on 14-8-27.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "db_model.h"

@interface emoticon_detail_info_model : db_model

+ (BOOL)insertEmoticonDetailInfoWithDic:(NSDictionary *)dic;

+ (BOOL)deleteAllData;

+ (NSDictionary *)getLatestDetailInfoDic;

@end
