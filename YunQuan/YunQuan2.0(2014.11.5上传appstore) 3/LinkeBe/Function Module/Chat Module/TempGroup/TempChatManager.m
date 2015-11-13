//
//  TempContactManager.m
//  LinkeBe
//
//  Created by Dream on 14-9-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "TempChatManager.h"
#import "LinkedBeHttpRequest.h"
#import "MajorCircleManager.h"
#import "UserModel.h"
#import "SnailSocketManager.h"
#import "SnailCommandFactory.h"
#import "ContactModel.h"
#import "TCCreateOrAddMemberData.h"
#import "LinkedBeHttpRequest.h"
#import "TempChat_list_model.h"
#import "SBJson.h"
#import "SnailNetWorkManager.h"
#import "SnailRequestGet.h"
#import "ChatMacro.h"
#import "MessageDataManager.h"
#import "TimeStamp_model.h"
#import "Common.h"
#import "SnailRequestPut.h"

typedef enum{
    TempCircleChangeTypeAdd = 1,
    TempCircleChangeTypeDelete  = 2
}TempCircleChangeType;

static int serialNumber = 0;

@interface TempChatManager () <HttpRequestDelegate>
{
    
}

@property (nonatomic, retain) NSMutableArray * waitForVerifyDataArr;

@end

@implementation TempChatManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.waitForVerifyDataArr = [[[NSMutableArray alloc]init] autorelease];
    }
    return self;
}

+ (TempChatManager *)shareManager
{
    static TempChatManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TempChatManager alloc]init];
    });
    return manager;
}

- (void)createTempChatWithContactArr:(NSMutableArray *)contactArr
{
    TCCreateOrAddMemberData * createData = [[TCCreateOrAddMemberData alloc]init];
    createData.memberArr = contactArr;
    createData.dataLocalID = [self getNextSerialNumber];
    createData.operateType = TCCADataTypeCreate;
    createData.tempCircleID = 0;
    [self sendCreateOrAddMemberData:createData];
    [self.waitForVerifyDataArr addObject:createData];
    RELEASE_SAFE(createData);
}

- (void)addMembersToTempChat:(long long)tempChatId andMemberArr:(NSMutableArray *)contactArr
{
    TCCreateOrAddMemberData * addmemberData = [[TCCreateOrAddMemberData alloc]init];
    addmemberData.memberArr = contactArr;
    addmemberData.dataLocalID = [self getNextSerialNumber];
    addmemberData.operateType = TCCADataTypeAdd;
    addmemberData.tempCircleID = tempChatId;
    [self sendCreateOrAddMemberData:addmemberData];
    [self.waitForVerifyDataArr addObject:addmemberData];
    RELEASE_SAFE(addmemberData);
}

//聚聚添加成员
- (void)addMembersToTogether:(long long)tempChatId andMemberArr:(NSMutableArray *)contactArr{
    TCCreateOrAddMemberData * addmemberData = [[TCCreateOrAddMemberData alloc]init];
    addmemberData.memberArr = contactArr;
    addmemberData.dataLocalID = [self getNextSerialNumber];
    addmemberData.operateType = TCCADataTypeAdd;
    addmemberData.tempCircleID = tempChatId;
    [self sendTogetherMemberData:addmemberData];
    [self.waitForVerifyDataArr addObject:addmemberData];
    RELEASE_SAFE(addmemberData);
}

-(void) sendTogetherMemberData:(TCCreateOrAddMemberData*) memberData{
    SnailCommandObject *contactCommand = [SnailCommandFactory commandObjectWithCommand: CMD_TOGETHER_ADDMEMBER andBodyDic:[memberData getiMSendDic] andReceiverID:memberData.tempCircleID];
    contactCommand.serialNumber = memberData.dataLocalID;
    [SnailSocketManager sendCommandObject:contactCommand];
}

- (void)sendCreateOrAddMemberData:(TCCreateOrAddMemberData *)memberData
{
    SnailCommandObject *contactCommand = [SnailCommandFactory commandObjectWithCommand: CMD_TEMCIRCLE_ADDMEMBER andBodyDic:[memberData getiMSendDic] andReceiverID:memberData.tempCircleID];
    contactCommand.serialNumber = memberData.dataLocalID;
    [SnailSocketManager sendCommandObject:contactCommand];
}

- (int)getNextSerialNumber
{
    return ++serialNumber;
}

- (void)createOrAddMemberAckWithDic:(NSDictionary *)ackDic andDataLocalID:(int)localID
{
    __block TCCreateOrAddMemberData * waitingData = nil;
    
    [self.waitForVerifyDataArr enumerateObjectsUsingBlock:^(TCCreateOrAddMemberData * obj, NSUInteger idx, BOOL *stop) {
        if (obj.dataLocalID == localID) {
            waitingData = obj;
            *stop = YES;
        }
    }];
    
    if (waitingData != nil) {
        long long circleId = [[ackDic objectForKey:@"gid"] longLongValue];
        switch (waitingData.operateType) {
            case TCCADataTypeAdd:
            {
        
                [self.delegate addMemberSuccessWithCircleID:circleId];
                [self.waitForVerifyDataArr removeObject:waitingData];
            }
                break;
            case TCCADataTypeCreate:
            {
                //创建
                NSLog(@"ackDic = %@",ackDic);
                //                [self retrieveTempCirleDetailWithTempCircleID:circleId andWaitingData:waitingData];
                [self.delegate createTempChatSuccessWithCircleID:circleId];
                [self.waitForVerifyDataArr removeObject:waitingData];
            }
                break;
            default:
                break;
        }
    }
}

- (void)retrieveTempCirleDetailWithTempCircleID:(long long)tempCircleID andWaitingData:(TCCreateOrAddMemberData *)waitingData
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithLongLong:tempCircleID],@"circleId",
                                @"0",@"ts",
                                nil];
    SnailRequestGet * getRequest = [[SnailRequestGet alloc]init];
    getRequest.command = LinkeBe_DetailTempChat;
    getRequest.requestParam = dic;
    getRequest.requestInterface = [NSString stringWithFormat:@"/tempsession/%lld",tempCircleID];
    
    NSMutableDictionary * paramDic = nil;
    if (waitingData != nil) {
        paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    waitingData,@"waitingData", nil];
    }
    [[SnailNetWorkManager shareManager]sendHttpRequest:getRequest fromDelegate:self andParam:paramDic];
    [getRequest release];
}

- (void)receiveMemberChangeWithCircleID:(long long)tampCircleID;
{
    [self retrieveTempCirleDetailWithTempCircleID:tampCircleID andWaitingData:nil];
}

- (void)receiveInfoChangeWithCircleID:(long long)tempCircleID
{
    [self retrieveTempCirleDetailWithTempCircleID:tempCircleID andWaitingData:nil];
}

- (void)quitTempCircleWithCircleID:(long long)tempCircleID
{
    TCOperationData * quitData = [[TCOperationData alloc]init];
    quitData.dataLocalID = [self getNextSerialNumber];
    quitData.tempCircleID = tempCircleID;

    [self.waitForVerifyDataArr addObject:quitData];
    
    SnailCommandObject * quitCommand = [SnailCommandFactory commandObjectWithCommand:CMD_QUIT_TEMP_CIRLE andBodyDic:[NSDictionary dictionary] andReceiverID:tempCircleID];
    quitCommand.serialNumber = quitData.dataLocalID;
    RELEASE_SAFE(quitData);

    [SnailSocketManager sendCommandObject:quitCommand];
}

- (void)quitTempCircleSuccessWithLocalID:(int)localID
{
    TCOperationData * quitData = [self getWaitDataForLocalID:localID];
    if (quitData != nil) {
        [TempChat_list_model deleteDataWithTempCircleID:quitData.tempCircleID];
        [MessageDataManager deleteChatDBdataWithTalkType:SessionTypeTempCircle andObjectID:quitData.tempCircleID];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:TempCircleQuitScucess object:nil];
}

- (TCOperationData *)getWaitDataForLocalID:(int)localID
{
    __block TCOperationData * resultData = nil;
    [self.waitForVerifyDataArr enumerateObjectsUsingBlock:^(TCOperationData * obj, NSUInteger idx, BOOL *stop) {
        if (obj.dataLocalID == localID) {
            resultData = obj;
            *stop = YES;
        }
    }];
    return resultData;
}

//修改临时会话名称
- (void)modifyTempContactName:(long long)circleId  circleName:(NSString *)name
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                name,@"name",
                                [[UserModel shareUser] user_id],@"userId",
                                nil];
    
    SnailRequestPut * request = [[SnailRequestPut alloc]init];
    request.requestInterface = [NSString stringWithFormat:@"/tempsession/name/%lld",circleId];
    request.command = LinkeBe_ModifyTempChatName;
    request.requestParam = dic;
    
    [[SnailNetWorkManager shareManager]sendHttpRequest:request fromDelegate:self andParam:nil];
    RELEASE_SAFE(request);
}

- (NSTimeInterval)getCurrentTimeStamb
{
    NSTimeInterval resultTime = [[NSDate date]timeIntervalSince1970];
    return resultTime;
}

- (void)didFinishCommand:(NSDictionary *)jsonDic cmd:(LinkedBe_WInterface)commandid withVersion:(int)ver andParam:(NSMutableDictionary *)param
{
    if (jsonDic == nil && commandid == LinkeBe_ModifyTempChatName) {
        [self.delegate modifyTempChatNameSuccess:jsonDic];
        return;
    }
    
    [Common securelyParseHttpResultDic:jsonDic andParseBlock:^{
        switch (commandid) {
                //临时会话详情
            case LinkeBe_DetailTempChat: {
                if (jsonDic) {
                    
                    NSDictionary *tempChatDic = [jsonDic objectForKey:@"circle"];
                    
                    long long tempCircleID = [[tempChatDic objectForKey:@"id"]longLongValue];
                    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:tempChatDic];
                    [tempDic setObject:[jsonDic objectForKey:@"members"] forKey:@"members"];
                    [tempDic setObject:[jsonDic objectForKey:@"ts"] forKey:@"ts"];
                    
                    //justin 那边数据异常会做修改暂时容错
                    [tempDic removeObjectForKey:@"imagePath"];

                    [TempChat_list_model insertOrUpdateTempChatListWithDic:tempDic];
                    
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:TempCircleMemberChanged object:nil];
                    
                    if (param != nil) {
                        TCCreateOrAddMemberData * watingData = [param objectForKey:@"waitingData"];
                        switch (watingData.operateType) {
                            case TCCADataTypeCreate:
                            {
                                [self.delegate createTempChatSuccessWithCircleID:tempCircleID];
                            }
                                break;
                            case TCCADataTypeAdd:
                            {
                                [self.delegate addMemberSuccessWithCircleID:tempCircleID];
                            }
                                break;
                            default:
                            {
                                [self.delegate refreshDetailInfoWithCircleID:[[tempChatDic objectForKey:@"id"] longLongValue]];
                            }
                                break;
                        }
                        
                    }
                }
            }
                break;
            case LinkeBe_ModifyTempChatName:{
                [self.delegate modifyTempChatNameSuccess:jsonDic];
               
            }
                break;

            default:
                break;
        }
        
    }];
}

- (void)dealloc
{
    self.waitForVerifyDataArr = nil;
    [super dealloc];
}

@end
