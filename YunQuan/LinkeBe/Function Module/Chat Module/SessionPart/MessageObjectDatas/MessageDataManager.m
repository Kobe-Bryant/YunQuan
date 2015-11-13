//
//  MessageDataManager.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MessageDataManager.h"
#import "MessageListData.h"
#import "MessageHistoryRecordTable_model.h"
#import "MessageListTable_model.h"
#import "ChatMacro.h"

@implementation MessageDataManager

static id m_messageDataManager;

+ (MessageDataManager *)shareMessageDataManager
{
    if (m_messageDataManager == nil) {
        m_messageDataManager = [[MessageDataManager alloc]init];
    }
    return m_messageDataManager;
}

- (BOOL)updateData:(MessageData *)msgData
{
    BOOL successJudgerHistory = NO;
    BOOL successJudgerList = NO;
    
    //跟新历史消息列表数据
    NSMutableDictionary *msgDic = [msgData getRestoreDBDic];
    successJudgerHistory = [MessageHistoryRecordTable_model insertOrUpdateDictionaryIntoList:msgDic];
    
    MessageListData * insertData = [self generateNewMessageListDataWithMessageData:msgData];
    NSMutableDictionary *listDic = [insertData getResoreDic];
    
    //跟新聊天列表消息
    successJudgerList = [MessageListTable_model insertOrUpdateRecordWithDic:listDic];
    return successJudgerList && successJudgerHistory;
}

- (BOOL)restoreData:(MessageData *)msgdata
{
    BOOL successJudgerHostory = [self insertDataWithMessage:msgdata];
    
    BOOL successJudgerList = [self freshListLatestMessage:msgdata];
    return successJudgerHostory && successJudgerList;
}

- (BOOL)freshListLatestMessage:(MessageData *)messageData
{
    int unreadPlus = 0;
    if (messageData.operationType == MessageOperationTypeReceive) {
    
        unreadPlus = 1;
    }
    NSDictionary * oldListDic = [MessageListTable_model getDicForSessionType:messageData.sessionType andObjectID:messageData.objectID];
    NSDictionary * newRestoreDic = nil;
    
    if (oldListDic == nil) {
        MessageListData * newData = [self generateNewMessageListDataWithMessageData:messageData];
        newData.unreadCount += unreadPlus;
        newRestoreDic = [newData getResoreDic];
    } else {
        MessageListData * oldData = [[MessageListData alloc]initWithDic:oldListDic];
        oldData.unreadCount += unreadPlus;
        oldData.latestMessage = messageData;
        newRestoreDic = [oldData getResoreDic];
        RELEASE_SAFE(oldData);
    }
   
    return [MessageListTable_model insertOrUpdateRecordWithDic:newRestoreDic];
}

- (MessageListData *)generateNewMessageListDataWithMessageData:(MessageData *)messageData
{
    MessageListData * newListData = [[MessageListData alloc]init];
    newListData.ObjectID = messageData.objectID;
    newListData.latestMessage = messageData;
    return [newListData autorelease];
}

- (BOOL)insertDataWithMessage:(MessageData *)msgData
{
    NSInteger nextID = [MessageHistoryRecordTable_model nextNewID];
    msgData.locmsgid = nextID;
    NSMutableDictionary * insetDic = [msgData getRestoreDBDic];
    
    BOOL successJudger = [MessageHistoryRecordTable_model insertOrUpdateDictionaryIntoList:insetDic];
    return successJudger;
}

+ (BOOL)deleteChatDBdataWithTalkType:(SessionType)talkType andObjectID:(long long)objectID
{
    BOOL successJudgerList = [MessageListTable_model deleteDataWithSessionType:talkType andObjectID:objectID];
    BOOL successJudgerHistory = [MessageHistoryRecordTable_model deleteAllChatDataWithObjectID:objectID andSessionType:talkType];
    return successJudgerList && successJudgerHistory;
}

+ (BOOL)deleteDBChatMessage:(MessageData *)data
{
    long long  messageID = data.locmsgid;
    return [MessageHistoryRecordTable_model deleteMessageRecordForID:messageID];
}

+ (MessageData *)generateSendModelData
{
    MessageData * resultData = [[MessageData alloc]init];
    resultData.operationType = MessageOperationTypeSend;
    resultData.statusType = MessageStatusTypeSending;
    return [resultData autorelease];
}

- (void)dealloc
{
    [super dealloc];
}

@end
