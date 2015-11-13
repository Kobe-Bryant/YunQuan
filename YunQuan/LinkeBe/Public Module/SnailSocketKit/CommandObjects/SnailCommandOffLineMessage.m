//
//  SnailCommandOffLineMessageObject.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandOffLineMessage.h"
#import "SessionDataOperator.h"
#import "MessageData.h"
#import "SnailSocketManager.h"
#import "SnailCommandFactory.h"

@implementation SnailCommandOffLineMessage

- (void)handleCommandData
{
    [self storeHistoryMsgAndSendACKWithSessionType:SessionTypePerson];
    
}

- (void)storeHistoryMsgAndSendACKWithSessionType:(SessionType)type
{
    NSArray *historyMsgArr = [self.bodyDic objectForKey:@"msglst"];
    
    if (historyMsgArr.count > 0) {
        for (NSDictionary * msgDic in historyMsgArr) {
            
            [self storeMessageAndSendItToOtherComponentWithMessageDic:msgDic andMessageType:type];
        }
        
//        if (type == SessionTypePerson) {
            MessageData * lastMessage = [[MessageData alloc]initWithIMReceiverDic:[historyMsgArr lastObject] andObjectID:self.senderID];
            lastMessage.sessionType = type;
            [self sendReceiveOffLineMessageACKToServerWithLastMeessage:lastMessage];
            RELEASE_SAFE(lastMessage);
//        }
    }
}


- (void)sendReceiveOffLineMessageACKToServerWithLastMeessage:(MessageData *)msgData
{
    NSDictionary * ackDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:0],@"rcode",
                             [NSNumber numberWithLongLong:msgData.msgid],@"recvmid",
                             [[UserModel shareUser] org_id],@"oid",
                             nil];
    switch (msgData.sessionType) {
        case SessionTypePerson:
        {
            SnailCommandObject * ackCommand = [SnailCommandFactory commandObjectWithCommand:CMD_PERSONAL_PUSHREC_ACK andBodyDic:ackDic andReceiverID:0];
            [SnailSocketManager sendCommandObject:ackCommand];
        }
            break;
        case SessionTypeTempCircle:
        {
            SnailCommandObject * ackCommand = [SnailCommandFactory commandObjectWithCommand:CMD_TEMP_CIRCLE_PUSHREC_ACK andBodyDic:ackDic andReceiverID:0];
            [SnailSocketManager sendCommandObject:ackCommand];
        }
            
        default:
            break;
    }
 
    
}

@end
