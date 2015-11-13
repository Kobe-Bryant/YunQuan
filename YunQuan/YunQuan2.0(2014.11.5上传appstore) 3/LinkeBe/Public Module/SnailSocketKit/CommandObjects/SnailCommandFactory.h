//
//  SnailCommandFactory.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailCommandObject.h"
#import "SnailCommandLogin.h"
#import "SnailCommandMsgSendFinish.h"
#import "SnailCommandHeartBeat.h"
#import "SnailCommandTCAddMemberACK.h"
#import "SnailCommandReceiveMessage.h"
#import "SnailCommandLoginOut.h"
#import "SnailCommandCompelLoginOut.h"
#import "SnailCommandDisable.h"
#import "SnailCommandComment.h"
#import "SnailCommandDynamicNotify.h"
#import "SnailCommandReceiveTCMsg.h"
#import "SnailCommandOffLineMessage.h"
#import "SnailCommandTCSendMsgACK.h"
#import "SnailCommandReceiveTCMsg.h"
#import "SnailCommandTCQuitACK.h"
#import "SnailCommandTCOffLineMsg.h"
#import "SnailCommandTCMemberChange.h"
#import "SnailCommandTCInfoChange.h"
#import "SnailCommandTCQuitACK.h"
#import "SnailCommandOrgMsgSendACK.h"
#import "SnailCommandOrgMsgReceive.h"
#import "SnailCommandOrgMemeberChangeNotify.h"
#import "SnailCommandOrgOrSecretaryOfflineMessage.h"

//booky
#import "SnailCommandDynamicDeleteNotify.h"
#import "SnailCommandAddTogetherMemberACK.h"


//用户登陆
#define CMD_USER_LOGIN                  0x0001
//用户登陆响应
#define CMD_USER_LOGIN_ACK              0x0002
//用户登出
#define CMD_USER_LOGOUT                 0x0003
//用户登出响应
#define CMD_USER_LOGOUT_ACK             0x0004

//被迫下线通知
#define CMD_FORCEDOWN_NTF               0x000c
//被禁用通知
#define CMD_USERDISABLE_NTF             0x000d

//客户端心跳发送
#define CMD_USER_HEARTBEAT              0x0005
//客户端心跳响应
#define CMD_USER_HEARTBEAT_ACK          0x0006
//单聊消息发送
#define CMD_PERSONAL_MSGSEND            0x0007
//单聊消息发送响应
#define CMD_PERSONAL_MSGSEND_ACK        0x0008
//单聊消息接收
#define CMD_PERSONAL_MSGRECV            0x0009
//单聊离线消息接收
#define CMD_PERSONAL_PUSHREC            0x000a
//单聊离线消息接收反馈
#define CMD_PERSONAL_PUSHREC_ACK        0x000b

//创建临时会话
#define CMD_TEMCIRCLE_ADDMEMBER         0x0050
//创建临时会话 添加成员 反馈
#define CMD_TEMCIRCLE_ADDMEMBER_ACK     0x0051
//评论动态通知
#define CMD_COMMENTS_REMIND             0x000e
//动态通知提醒
#define CMD_DYNAMIC_REMIND              0x000f
//动态删除通知
#define CMD_DYNAMIC_DELETE_REMIND       0x0010
//临时会话消息发送
#define CMD_TEMP_CIRCLE_MSGSEND         0x0052
//临时会话消息发送反馈
#define CMD_TEMP_CIRCLE_MSGSEND_ACK     0x0053
//收到临时会话消息
#define CMD_TEMP_CIRCLE_MSGRECV         0x0054
//临时会话历史消息
#define CMD_TEMP_CIRCLE_PUSHREC         0x0055
//临时会话成员变更
#define CMD_TEMP_CIRCLEMEMBER_CHG_NTF   0x0056
//临时会话信息变更通知
#define CMD_TEMP_CIRCLE_CHG_NTF         0x0057

//临时会话主动退出
#define CMD_QUIT_TEMP_CIRLE             0x0058

//临时会话主动退出回调
#define CMD_QUIT_TEMP_CIRLE_ACK         0x0059

//聚聚添加成员
#define CMD_TOGETHER_ADDMEMBER          0x005a

//聚聚添加成员反馈
#define CMD_TOGETHER_ADDMEMBER_ACK      0x005b

//组织方和小秘书发送消息回馈
#define CMD_ORG_MSGSEND                 0x0150

#define CMD_ORG_MSGSEND_ACK             0x0151
//组织方和小秘书消息接收
#define CMD_ORG_MSGRECV                 0x0152
//组织成员变更通知
#define CMD_CIRCLEMEMBER_CHG_NTF        0x0153
//离线推送临时圈子离线消息记录回馈
#define CMD_TEMP_CIRCLE_PUSHREC_ACK     0x005c
//临时圈子成员变更ACK
#define CMD_TEMP_CIRCLEMEMBER_CHG_NTF_ACK 0x005d
//临时圈子信息变更ACK
#define CMD_TEMP_CIRCLE_CHG_NTF_ACK     0x005e
//组织方发送消息ACK
#define CMD_ORG_MSGRECV_ACK             0x005d
//组织方离线消息推送
#define CMD_ORG_PUSHREC                 0x0154

@interface SnailCommandFactory : NSObject

+ (SnailCommandObject *)commandObjectWithCommand:(int)command andBodyDic:(NSDictionary *)bodyDic andReceiverID:(long long)receiverID;

+ (SnailCommandObject *)commandObjectWithData:(NSData *)data;

@end
