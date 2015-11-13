//
//  SnailCommandFactory.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandFactory.h"
#import "NSData+SocketAddiction.h"
#import "UserModel.h"

@implementation SnailCommandFactory

+ (SnailCommandObject *)commandObjectWithCommand:(int)command andBodyDic:(NSDictionary *)bodyDic andReceiverID:(long long)receiverID
{
    SnailCommandObject * object = [[SnailCommandObject alloc]init];
    object.command = command;
    object.bodyDic = bodyDic;
    object.senderID = [[[UserModel shareUser]user_id]longLongValue];
    object.receiverID = receiverID;
    
    NSLog(@"SendMessaeBodyDic = %@",bodyDic);
    
    return [object autorelease];
}

+ (SnailCommandObject *)commandObjectWithData:(NSData *)data
{
    int command = [data rw_int16AtOffset:10];
    SnailCommandObject * commandObject = nil;
    
    switch (command) {
        case CMD_USER_LOGIN_ACK:
        {
            commandObject = [[[SnailCommandLogin alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_USER_HEARTBEAT_ACK:
        {
            commandObject = [[[SnailCommandHeartBeat alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_PERSONAL_PUSHREC:
        {
            commandObject = [[[SnailCommandOffLineMessage alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_PERSONAL_MSGSEND_ACK:
        {
            commandObject = [[[SnailCommandMsgSendFinish alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_TEMCIRCLE_ADDMEMBER_ACK:
        {
            commandObject = [[[SnailCommandTCAddMemberACK alloc]initWithData:data] autorelease];
        }
            break;
        case CMD_TOGETHER_ADDMEMBER_ACK:
        {
            commandObject = [[[SnailCommandAddTogetherMemberACK alloc]initWithData:data] autorelease];
        }
            break;
        case CMD_PERSONAL_MSGRECV:
        {
            commandObject = [[[SnailCommandReceiveMessage alloc]initWithData:data] autorelease];
        }
            break;
        case CMD_USER_LOGOUT_ACK:
        {
            commandObject = [[[SnailCommandLoginOut alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_FORCEDOWN_NTF:
        {
            commandObject = [[[SnailCommandCompelLoginOut alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_USERDISABLE_NTF:
        {
            commandObject = [[[SnailCommandDisable alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_COMMENTS_REMIND:
        {
            commandObject = [[[SnailCommandComment alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_DYNAMIC_REMIND:
        {
            commandObject = [[[SnailCommandDynamicNotify alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_DYNAMIC_DELETE_REMIND:
        {
            commandObject = [[[SnailCommandDynamicDeleteNotify alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_TEMP_CIRCLE_MSGSEND_ACK:
        {
            commandObject = [[[SnailCommandTCSendMsgACK alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_TEMP_CIRCLE_MSGRECV:
        {
            commandObject = [[[SnailCommandReceiveTCMsg alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_TEMP_CIRCLE_PUSHREC:
        {
            commandObject = [[[SnailCommandTCOffLineMsg alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_TEMP_CIRCLEMEMBER_CHG_NTF:
        {
            commandObject = [[[SnailCommandTCMemberChange alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_TEMP_CIRCLE_CHG_NTF:
        {
            commandObject = [[[SnailCommandTCInfoChange alloc] initWithData:data]autorelease];
        }
            break;
        case CMD_QUIT_TEMP_CIRLE_ACK:
        {
            commandObject = [[[SnailCommandTCQuitACK alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_ORG_MSGSEND_ACK:
        {
            commandObject = [[[SnailCommandOrgMsgSendACK alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_ORG_MSGRECV:
        {
            commandObject = [[[SnailCommandOrgMsgReceive alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_CIRCLEMEMBER_CHG_NTF:
        {
            commandObject = [[[SnailCommandOrgMemeberChangeNotify alloc]initWithData:data]autorelease];
        }
            break;
        case CMD_ORG_PUSHREC:
        {
            commandObject = [[[SnailCommandOrgOrSecretaryOfflineMessage alloc]initWithData:data] autorelease];
        }
            break;
        default:
            break;
    }
    return commandObject;
}

@end
