//
//  MessageHistoryRecordTable_model.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"
#import "MessageListData.h"

@interface MessageHistoryRecordTable_model : db_model

+ (NSMutableArray *)getMessagesWithObjectID:(long long)objectID andSessionType:(SessionType)type;

+ (BOOL)insertOrUpdateDictionaryIntoList:(NSDictionary *)dic;

+ (BOOL)deleteAllChatDataWithObjectID:(long long)objectID andSessionType:(SessionType)type;

+ (NSDictionary *)getLatestMessageDicWithObjectID:(long long)objectID andSessionType:(SessionType)type;

+ (BOOL)deleteMessageRecordForID:(long long)messageLocalID;

+ (NSInteger)nextNewID;

+ (NSMutableArray *)getHistoryWithObjectID:(long long)objectID CurrentPage:(int)currentPage andPageNumber:(int)pageNumber;

+ (NSDictionary *)getMessageForMsgid:(long long)mid;


@end
