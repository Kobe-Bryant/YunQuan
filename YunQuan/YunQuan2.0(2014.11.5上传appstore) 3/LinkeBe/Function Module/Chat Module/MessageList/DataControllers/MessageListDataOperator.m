//
//  MessageListDataOperator.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-18.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MessageListDataOperator.h"
#import "HttpRequest.h"
#import "MessageListData.h"
#import "SessionDataFactory.h"
#import "MessageListTable_model.h"
#import "SnailRequestGet.h"
#import "SnailNetWorkManager.h"
#import "SessionDataOperator.h"
#import "SBJson.h"
#import "SecretaryOrgInfoTable_model.h"
#import "SecretarySingleton.h"
#import "OrgSingleton.h"
#import "EmotionStoreManager.h"
#import "MessageDataManager.h"
#import "AppDelegate.h"
#import "TimeStamp_model.h"


static id operator = nil;

@interface MessageListDataOperator () <HttpRequestDelegate,EmotionStroeManagerDelegate>
{
    
}

@end

@implementation MessageListDataOperator

+ (instancetype)shareOperator
{
    if (operator == nil) {
        operator = [[MessageListDataOperator alloc]init];
    }
    return operator;
}

- (void)getFirstInWelcomeMessage
{
    //    if ([self isFirstInMessageListView]) {
    //    NSMutableArray * arr = [self getTestMessageArr];
    //    [self.delegate getFirstInWelcomeMessageSuccessWithDataArr:arr];
    [self sendWelcomeMessageRequest];
    //    }
    
}

- (void)getFirstInstallEmotion
{
    if ([self isFirstInMessageListView]) {
        EmotionStoreManager * emoticonManager = [[EmotionStoreManager alloc]init];
        emoticonManager.delegate = self;
        [emoticonManager judgeFirstInstallAndLoadDownloadedEmoticon];
    }
}

- (void)sendWelcomeMessageRequest
{
    long long timeStamp = [TimeStamp_model getTimeStampWithType:WELCOMEMESSAGE];
    SnailRequestGet * welcomeGeter = [[SnailRequestGet alloc]init];
    welcomeGeter.command = LinkedBe_Command_GetWelcomeMsg;
    welcomeGeter.requestInterface = @"/system/welcome";
    welcomeGeter.requestParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [[UserModel shareUser]user_id],@"userId",
                                 [[UserModel shareUser] org_id],@"orgId",
                                 [NSNumber numberWithLongLong:timeStamp],@"ts", nil];
    
    [[SnailNetWorkManager shareManager]sendHttpRequest:welcomeGeter fromDelegate:self andParam:nil];
    RELEASE_SAFE(welcomeGeter);
}

- (BOOL)isFirstInMessageListView
{
    NSMutableDictionary * orgDic = (NSMutableDictionary *)[SecretaryOrgInfoTable_model getObjectInfoDicWithObject_type:SpecialContectOrg];
    NSMutableDictionary * secretary = (NSMutableDictionary *)[SecretaryOrgInfoTable_model getObjectInfoDicWithObject_type:SpecialContectSecretary];
    
    if (orgDic != nil && secretary != nil) {
        [self generateSingletonWithDic:orgDic];
        [self generateSingletonWithDic:secretary];
        
        return NO;
    }
    return YES;
}

- (NSMutableArray *)getDBMessageListDataArr
{
    NSMutableArray * dbArr = [MessageListTable_model getAllDataList];
    
    NSMutableArray * messages = [[NSMutableArray alloc]initWithCapacity:dbArr.count];
    for (NSDictionary *listDic in  dbArr) {
        MessageListData *listData = [[MessageListData alloc]initWithDic:listDic];
        [messages addObject:listData];
        RELEASE_SAFE(listData);
    }
    
    [messages sortUsingComparator:^NSComparisonResult(MessageListData *obj1, MessageListData *obj2) {
        return obj1.latestMessage.msgid > obj2.latestMessage.msgid ? NSOrderedAscending : NSOrderedDescending;
    }];
    return [messages autorelease];
}

- (void)listReceiveNewMessage:(MessageData *)message
{
    [self.delegate receiveNewDataMessage:message];
}


- (void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver
{
    [Common securelyParseHttpResultDic:jsonDic andParseBlock:^{
        switch (commandid) {
            case LinkedBe_Command_GetWelcomeMsg:
            {
                NSArray * welcomeArr = [jsonDic objectForKey:@"welcomes"];
                
                if (welcomeArr.count > 0) {
                    long long timeStamp = [[jsonDic objectForKey:@"ts"]longLongValue];
                    [TimeStamp_model insertOrUpdateType:WELCOMEMESSAGE time:timeStamp];
                }
                for (NSDictionary *welcomeDic in welcomeArr) {
                    SpecialContect type = [[welcomeDic objectForKey:@"type"]intValue];
                    NSMutableDictionary * specialObjectDic = [self singletonDicWithWidth:welcomeDic];
                    [self generateSingletonWithDic:specialObjectDic];
                    
                    if ([self isFirstInMessageListView]) {
                        switch (type) {
                            case SpecialContectSecretary:
                            {
                                [self receiveMsgWithHttpDic:welcomeDic];
                            }
                                break;
                            case SpecialContectOrg:
                            {
                                [self receiveMsgWithHttpDic:welcomeDic];
                            }
                                break;
                            default:
                                break;
                        }
                    }

                    [self restoreSingletonToSpecialDB:specialObjectDic];
                }
            }
                break;
            default:
                break;
        }
    }];
}

- (void)receiveMsgWithHttpDic:(NSDictionary *)welcomeDic
{
    NSArray *msgArr = [welcomeDic objectForKey:@"msg"];
    NSDictionary * speakerDic = [welcomeDic objectForKey:@"speakerinfo"];
    
    long long objectID = [[speakerDic objectForKey:@"uid"]longLongValue];
    
    for (NSDictionary *msgDic in msgArr) {
        OriginData * msgData = [SessionDataFactory generateInstantDataWithDic:msgDic];
        
        MessageData * secretaryMsg = [[MessageData alloc]init];
        secretaryMsg.objectID = objectID;
        secretaryMsg.sessionData = msgData;
        secretaryMsg.operationType = MessageOperationTypeReceive;
        secretaryMsg.sessionType = SessionTypePerson;
        secretaryMsg.sendtime = [[NSDate date]timeIntervalSince1970];
        secretaryMsg.msgid = [[NSDate date]timeIntervalSince1970] * MessageMidPlus;
        [secretaryMsg judgeShowTimeIndicator];
        
        ObjectData * speaker = [ObjectData objectFromMemberListWithID:objectID];
        secretaryMsg.speaker = speaker;
        
        [[SessionDataOperator shareOperator]receiveNewMessageWithMessageData:secretaryMsg];
        [self listReceiveNewMessage:secretaryMsg];
        
        RELEASE_SAFE(secretaryMsg);
    }
}

- (void)restoreSingletonToSpecialDB:(NSMutableDictionary *)restoreDic
{
    [SecretaryOrgInfoTable_model insertOrUpdateInfoWithDic:restoreDic];
}

- (NSMutableDictionary *)singletonDicWithWidth:(NSDictionary *)welcomeDic
{
    NSDictionary * speakerDic = [welcomeDic objectForKey:@"speakerinfo"];
    NSMutableDictionary * specialObjectDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[speakerDic objectForKey:@"uid"],@"uid",
                                              [speakerDic objectForKey:@"realname"],@"realname",
                                              [welcomeDic objectForKey:@"type"],@"type",
                                              [speakerDic objectForKey:@"portrait"],@"portrait",
                                              [speakerDic objectForKey:@"orgUserId"],@"orgUserId",
                                              nil];
    return specialObjectDic;
}

- (void)generateSingletonWithDic:(NSMutableDictionary *)dic
{
    SpecialContect type = [[dic objectForKey:@"type"]intValue];
    long long userID = [[dic objectForKey:@"uid"]longLongValue];
    NSString *name = [dic objectForKey:@"realname"];
    NSString *portrait = [dic objectForKey:@"portrait"];
    int orgUserID = [[dic objectForKey:@"orgUserId"]intValue];
    
    switch (type) {
        case SpecialContectSecretary:
        {
            [SecretarySingleton shareSecretary].secretaryID = userID;
            [SecretarySingleton shareSecretary].secretaryName = name;
            [SecretarySingleton shareSecretary].secretaryPortrait = portrait;
            [SecretarySingleton shareSecretary].orgUserId = orgUserID;
        }
            break;
        case SpecialContectOrg:
        {
            [OrgSingleton shareOrg].orgID = userID;
            [OrgSingleton shareOrg].orgName = name;
            [OrgSingleton shareOrg].orgPortrait = portrait;
            [OrgSingleton shareOrg].orgUserId = orgUserID;
        }
            break;
        default:
            break;
    }
    
}

- (void)cleanUnreadSignForChatObjectID:(long long)objectID andSessionType:(SessionType)type
{
    NSDictionary * oldDic = [MessageListTable_model getDicForSessionType:type andObjectID:objectID];
    if (oldDic != nil) {
        MessageListData *data = [[MessageListData alloc]initWithDic:oldDic];
        data.unreadCount = 0;
        
        NSDictionary *newDic = [data getResoreDic];
        [MessageListTable_model insertOrUpdateRecordWithDic:newDic];
        RELEASE_SAFE(data);
    }
    
    [[UIApplication sharedApplication].delegate performSelector:@selector(refreshChatItemUnreadNumber)];
}

- (void)deleteDBRecordWithListData:(MessageListData *)listData
{
    [MessageDataManager deleteChatDBdataWithTalkType:listData.latestMessage.sessionType andObjectID:listData.ObjectID];
}

+ (NSInteger)getAllUnreadMessageCount
{
    NSInteger allUnreadCount = 0;
    NSMutableArray * allDataList =  [MessageListTable_model getAllDataList];
    if (allDataList.count > 0) {
        for (NSDictionary * dataInfo in allDataList) {
            NSInteger unread = [[dataInfo objectForKey:@"unread_count"]intValue];
            allUnreadCount += unread;
        }
    }
    return allUnreadCount;
}

#pragma mark - EmotionStoreManagerDelegate
- (void)getEmotionStoreDataSuccessWithDic:(NSDictionary *)dataDic sender:(EmotionStoreManager *)sender
{
    NSArray * emoticonsArr = [dataDic objectForKey:@"emoticons"];
    for (NSDictionary * emoticonDic in emoticonsArr) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger emoticonID = [[emoticonDic objectForKey:@"packetId"]integerValue];
            EmotionStoreManager * detailManager = [[EmotionStoreManager alloc]init];
            detailManager.delegate = self;
            BOOL sign = [detailManager judgeShouldAndLoadDownloadedDetailEmoticonWithEmoticonID:emoticonID];
            if (!sign) {
                RELEASE_SAFE(detailManager);
            }
        });
    }
    
    RELEASE_SAFE(sender);
}

@end
