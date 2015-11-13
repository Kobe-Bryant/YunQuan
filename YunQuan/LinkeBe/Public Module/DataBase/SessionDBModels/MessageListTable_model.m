//
//  MessageListTable_model.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MessageListTable_model.h"
#import "UserModel.h"

@implementation MessageListTable_model

+ (NSMutableArray *)getAllDataList
{
    MessageListTable_model *geter = [[MessageListTable_model alloc]init];    
    NSMutableArray * dataArr = [geter getList];
    RELEASE_SAFE(geter);
    return dataArr;
}

+ (BOOL)insertOrUpdateRecordWithDic:(NSDictionary *)dic
{
    long long listID = [[dic objectForKey:@"object_id"]longLongValue];
    SessionType type = [[dic objectForKey:@"session_type"]intValue];
    
    MessageListTable_model *geter = [[MessageListTable_model alloc]init];
    geter.where = [NSString stringWithFormat:@"object_id = %lld and session_type = %d",listID,type];
    
    return [db_model updateDataWithModel:geter withDic:dic];
}

+ (BOOL)deleteDataWithSessionType:(SessionType)type andObjectID:(long long)objID
{
    MessageListTable_model *geter = [[MessageListTable_model alloc]init];
    geter.where = [NSString stringWithFormat:@"object_id = %lld and session_type = %d",objID,type];
    return [db_model deleteAllDataWithModel:geter];
}

+ (NSMutableDictionary *)getDicForSessionType:(SessionType)sessionType andObjectID:(long long)objectID
{
    MessageListTable_model *geter = [[MessageListTable_model alloc]init];
    geter.where = [NSString stringWithFormat:@"object_id = %lld and session_type = %d",objectID,sessionType];
    NSArray *list = [geter getList];
    NSMutableDictionary *resultDic = nil;
    if (list.count > 0) {
        resultDic = [list firstObject];
    }
    return resultDic;
}

@end
