//
//  MessageData.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MessageData.h"
#import "SBJson.h"
#import "MessageHistoryRecordTable_model.h"
#import "ObjectData.h"
#import "SessionDataOperator.h"

@implementation MessageData

- (instancetype)initWithDBDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.msgid = [[dic objectForKey:@"mid"]longLongValue];
        
        self.sendtime = [[dic objectForKey:@"time"]intValue];
        self.objectID = [[dic objectForKey:@"object_id"]longLongValue];
        self.sessionType = [[dic objectForKey:@"session_type"]intValue];
        self.locmsgid = [[dic objectForKey:@"id"]intValue];
        self.showTimeSign = [[dic objectForKey:@"show_time"]boolValue];
        self.operationType = [[dic objectForKey:@"operation_type"]intValue];
        self.statusType = [[dic objectForKey:@"sendStatus"]intValue];
        self.sessionData =  [SessionDataFactory generateInstantDataWithDic:[[dic objectForKey:@"msg"] JSONValue]];
        
        NSDictionary * speakerInfo = [[dic objectForKey:@"spkinfo"] JSONValue];
        long long spekerID = [[speakerInfo objectForKey:@"uid"]longLongValue];
        ObjectData * speaker = [ObjectData objectFromMemberListWithID:spekerID];
        self.speaker = (SpeakerData *)speaker;
       }

    return self;
}

- (instancetype)initWithIMReceiverDic:(NSDictionary *)dic andObjectID:(long long)objectID;
{
    self = [super init];
    if (self) {
        self.msgid = [[dic objectForKey:@"mid"]longLongValue];
        NSDictionary * speakerInfoDic = [dic objectForKey:@"spkinfo"];
        long long uid = [[speakerInfoDic objectForKey:@"uid"]longLongValue];
        self.speaker = (SpeakerData *)[ObjectData speakerForSpekerID:uid];
        self.sendtime = [[dic objectForKey:@"time"]intValue];
        self.objectID = objectID;
        self.operationType = MessageOperationTypeReceive;
        NSDictionary * sessionDataDic = [dic objectForKey:@"msg"];
        if (![sessionDataDic isKindOfClass:[NSNull class]]) {
            self.sessionData = [SessionDataFactory generateInstantDataWithDic:sessionDataDic];
        }
    }
    return self;
}

- (void)setStatusType:(MessageStatusType)statusType
{
    _statusType = statusType;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(messageDataStatusChange:)]) {
        [self.delegate messageDataStatusChange:self];
    }
}

- (NSMutableDictionary *)getRestoreDBDic
{
    NSMutableDictionary * resultDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithLongLong:self.locmsgid],@"id",
                                       [NSNumber numberWithLongLong:self.objectID],@"object_id",
                                       [NSNumber numberWithInt:self.sessionType],@"session_type",
                                       [NSNumber numberWithInt:self.operationType],@"operation_type",
                                       [NSNumber numberWithInt:self.sendtime],@"time",
                                       [NSNumber numberWithLongLong:self.msgid],@"mid",
                                       [NSNumber numberWithInt:self.showTimeSign],@"show_time",
                                        [[self.sessionData getDic] JSONRepresentation],@"msg",
                                        [[self.speaker getRestoreDic] JSONRepresentation],@"spkinfo",
                                       [NSNumber numberWithInt:self.statusType],@"sendStatus",
                                       nil];
    return resultDic;
}

- (NSDictionary *)getiMSendDic
{    
    NSDictionary * sendDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithLongLong:self.locmsgid],@"locmid",
                              [self.sessionData getDic],@"msg", nil];
    return sendDic;
}

- (void)judgeShowTimeIndicator
{
    dispatch_queue_t dbModifyQueue = [SessionDataOperator shareOperator].dbModifyDispatchQueue;
    dispatch_sync(dbModifyQueue, ^{
        NSDictionary * latestMessageDic = [MessageHistoryRecordTable_model getLatestMessageDicWithObjectID:self.objectID andSessionType:self.sessionType];
        if (latestMessageDic != nil) {
            NSTimeInterval latestMsgTime = [[latestMessageDic objectForKey:@"time"]doubleValue];
            NSDate * currentDate = [[NSDate alloc]init];
            NSTimeInterval now = [currentDate timeIntervalSince1970];
            NSTimeInterval distant = now - latestMsgTime;
            RELEASE_SAFE(currentDate);
            
            if (distant > MessageShowTimeInterval) {
                self.showTimeSign = YES;
            }
        } else {
            self.showTimeSign = YES;
        }
    });
}

- (id)copyWithZone:(NSZone *)zone
{
    MessageData * copyNewData = [[MessageData alloc]init];
    copyNewData.objectID = self.objectID;
    copyNewData.locmsgid = self.locmsgid;
    copyNewData.showTimeSign = self.showTimeSign;
    copyNewData.msgid = self.msgid;
    copyNewData.sendtime = self.sendtime;
    copyNewData.statusType = self.statusType;
    copyNewData.sessionType = self.sessionType;
    copyNewData.operationType = self.operationType;
    copyNewData.sendData = self.sendData;
    copyNewData.delegate = self.delegate;
    copyNewData.speaker = [[self.speaker copy] autorelease];
    copyNewData.sessionData = [[self.sessionData copy]autorelease];
    return copyNewData;
}

- (BOOL)judgeHaveBeenReceived
{
    NSDictionary * oldMsgDic = [MessageHistoryRecordTable_model getMessageForMsgid:self.msgid];
    if (oldMsgDic != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (void)dealloc
{
    self.delegate = nil;
    self.speaker = nil;
    self.sessionData = nil;
    self.sendData = nil;
    [super dealloc];
}

@end
