//
//  SnailCommandReceiveMessage.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-26.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandReceiveMessage.h"
#import "SessionDataOperator.h"
#import "MessageListDataOperator.h"
#import "SocketMessageLocalNotify.h"
#import "AppDelegate.h"
#import "SecretarySingleton.h"
#import "OrgSingleton.h"
#import "SnailCommandFactory.h"
#import "SnailSocketManager.h"

@implementation SnailCommandReceiveMessage

- (void)handleCommandData
{
    [self storeMessageAndSendItToOtherComponentWithMessageDic:self.bodyDic andMessageType:SessionTypePerson];
}

- (void)storeMessageAndSendItToOtherComponentWithMessageDic:(NSDictionary *)dic andMessageType:(SessionType)type
{
    long long senderID ;
    switch (type) {
        case SessionTypePerson:
        {
            senderID = [[[dic objectForKey:@"spkinfo"]objectForKey:@"uid"]longLongValue];
        }
            break;
        case SessionTypeTempCircle:
        {
            senderID = self.senderID;
        }
            break;
        default:
            break;
    }
    
    NSLog(@"Message Body Dic = %@",dic);
    MessageData * receiveData = [[MessageData alloc]initWithIMReceiverDic:dic andObjectID:senderID];
    receiveData.sessionData.dataStatus = OriginDataStatusUnread;
    receiveData.sessionType = type;
    [receiveData judgeShowTimeIndicator];

    //会话框检测消息接收
    [[SessionDataOperator shareOperator]receiveNewMessageWithMessageData:receiveData];
    //聊天列表收到新消息刷新界面
    [[MessageListDataOperator shareOperator]listReceiveNewMessage:receiveData];
    //刷新下bar未读消息
    [[UIApplication sharedApplication].delegate  performSelector:@selector(refreshChatItemUnreadNumber)];
    
    //-------booky-------//
    switch (type) {
        case SessionTypePerson:
        {
            [SocketMessageLocalNotify singleMessageNotify:dic];
        }
            break;
        case SessionTypeTempCircle:
        {
            [SocketMessageLocalNotify circleMessageNotify:dic];
        }
            break;
        default:
            break;
    }
    //-------booky-------//
    RELEASE_SAFE(receiveData);
    
    if (senderID == [[SecretarySingleton shareSecretary] secretaryID] || senderID == [[OrgSingleton shareOrg]orgID]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:0],@"rcode",
                             [[UserModel shareUser] org_id],@"oid",
                             [NSNumber numberWithLongLong:receiveData.msgid],@"mid", nil];
        SnailCommandObject * ackCommand = [SnailCommandFactory commandObjectWithCommand:CMD_TEMP_CIRCLE_CHG_NTF_ACK andBodyDic:dic andReceiverID:self.senderID];
        [SnailSocketManager sendCommandObject:ackCommand];
    }
}

@end
