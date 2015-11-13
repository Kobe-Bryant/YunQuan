//
//  emotion_list_model.h
//  ql
//
//  Created by LazySnail on 14-8-27.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "db_model.h"

@interface emoticon_list_model : db_model

+ (BOOL)insertOrUpdateListWithDic:(NSDictionary *)dic;

+ (BOOL)deleteListWithEmoticonID:(long long)emoticonID;

+ (BOOL)deleteAllData;

+ (NSDictionary *)getEmoticonDicWithEmoticonID:(long long)emotionID;

+ (NSMutableArray *)getAllEmoticons;

+ (NSMutableArray *)getDownloadedEmoticons;

@end
