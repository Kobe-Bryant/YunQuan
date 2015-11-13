//
//  MessageHistoryRecordTable_model.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MessageHistoryRecordTable_model.h"
#import "UserModel.h"

@implementation MessageHistoryRecordTable_model

+ (NSMutableArray *)getMessagesWithObjectID:(long long)objectID andSessionType:(SessionType)type
{
    
    MessageHistoryRecordTable_model *geter =[[MessageHistoryRecordTable_model alloc]init];
    geter.where = [self generateWhereStrWithObjectID:objectID andSessionType:type];
    NSMutableArray *messageArr = [geter getList];
    RELEASE_SAFE(geter);
    return messageArr;
}

+ (BOOL)insertOrUpdateDictionaryIntoList:(NSDictionary *)dic
{
    NSNumber * msgID = [dic objectForKey:@"id"];
    
    MessageHistoryRecordTable_model *geter = [[MessageHistoryRecordTable_model alloc]init];
    geter.where = [NSString stringWithFormat:@"id = %lld",msgID.longLongValue];
    return [db_model updateDataWithModel:geter withDic:dic];
}

+ (NSDictionary *)getMessageForMsgid:(long long)mid
{
    MessageHistoryRecordTable_model *geter = [[MessageHistoryRecordTable_model alloc]init];
    geter.where = [NSString stringWithFormat:@"mid = %lld",mid];
    NSArray * oldMsg = [geter getList];
    if (oldMsg.count > 0) {
        return [oldMsg firstObject];
    } else {
        return nil;
    }
}

+ (BOOL)deleteAllChatDataWithObjectID:(long long)objectID andSessionType:(SessionType)type
{
    MessageHistoryRecordTable_model *geter = [[MessageHistoryRecordTable_model alloc]init];
    NSString * whereStr = [self generateWhereStrWithObjectID:objectID andSessionType:type];

    geter.where = whereStr;
    return [db_model deleteAllDataWithModel:geter];
}

+ (NSString *)generateWhereStrWithObjectID:(long long)objectID andSessionType:(SessionType)type
{

    NSString *whereStr = [NSString stringWithFormat:@"(object_id = %lld and session_type = %d)",objectID,type];
    return whereStr;
}

+ (NSDictionary *)getLatestMessageDicWithObjectID:(long long)objectID andSessionType:(SessionType)type
{
    NSString *whereStr = [self generateWhereStrWithObjectID:objectID andSessionType:type];
    NSString *descStr = [NSString stringWithFormat:@"%@ order by time desc",whereStr];
    
    MessageHistoryRecordTable_model * geter = [[MessageHistoryRecordTable_model alloc]init];
    geter.where = descStr;
    
    NSDictionary * resultDic = nil;
    NSArray * list = [geter getList];
    if (list.count > 0) {
        resultDic = [list firstObject];
    }
    return resultDic;
}

+ (BOOL)deleteMessageRecordForID:(long long)messageLocalID
{
    MessageHistoryRecordTable_model * operator = [[MessageHistoryRecordTable_model alloc]init];
    operator.where = [NSString stringWithFormat:@"id = %lld",messageLocalID];
    BOOL judger = [operator deleteDBdata];
    return judger;
}

+ (NSInteger)nextNewID
{
    MessageHistoryRecordTable_model *geter = [[MessageHistoryRecordTable_model alloc]init];
    geter.where = [NSString stringWithFormat:@"object_id != 0 order by id desc"];
    NSArray * list = [geter getList];
    RELEASE_SAFE(geter);
    NSDictionary * latestDic = [list firstObject];
    NSInteger resultInt = [[latestDic objectForKey:@"id"]intValue];
    return ++resultInt;
}

+ (NSMutableArray *)getHistoryWithObjectID:(long long)objectID CurrentPage:(int)currentPage andPageNumber:(int)pageNumber
{
    NSString * whereStr = [NSString stringWithFormat:@"object_id = %lld order by mid desc",objectID];
    MessageHistoryRecordTable_model * geter = [[MessageHistoryRecordTable_model alloc]init];
    geter.where = whereStr;
    
    NSMutableArray * list = [geter fromPageNumber:currentPage pageNumber:pageNumber];
    RELEASE_SAFE(geter);
    return list;
}

@end
