//
//  MessageListTable_model.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"
#import "MessageListData.h"

@interface MessageListTable_model : db_model

//获取所有列表数据
+ (NSMutableArray *)getAllDataList;

//获取指定id 的列表数据
+ (NSMutableDictionary *)getDicForSessionType:(SessionType)sessionType andObjectID:(long long)objectID;

//根据所给字典插入一条list数据
+ (BOOL)insertOrUpdateRecordWithDic:(NSDictionary *)dic;

//根据id 和类型来删除列表记录
+ (BOOL)deleteDataWithSessionType:(SessionType)type andObjectID:(long long)objID;
@end
