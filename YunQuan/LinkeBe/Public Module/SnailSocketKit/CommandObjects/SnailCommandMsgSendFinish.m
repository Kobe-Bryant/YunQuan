//
//  SnailMessageSendFinishCommand.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandMsgSendFinish.h"
#import "ChatMacro.h"
#import "Common.h"
#import "SessionDataOperator.h"

typedef enum {
    ErrorCodeSuccess = 0,
    ErrorCodeFaild = 1,
    ErrorCodeNotLogin = 3,
    ErrorCodeReceiverIDZero = 4,
    ErrorCodeNotAtCircleAnyMore = 5,
}ErrorCode;

@implementation SnailCommandMsgSendFinish

- (void)handleCommandData
{
    [self judgeAckCodeAndNotifyOtherComponent];
}

- (void)judgeAckCodeAndNotifyOtherComponent
{
    ErrorCode recode = [[self.bodyDic objectForKey:@"rcode"]intValue];
    switch (recode) {
        case ErrorCodeSuccess:
        {
            [[SessionDataOperator shareOperator] receiveSendMessageSuccessWithDic:self.bodyDic];
        }
            break;
        case ErrorCodeFaild:
        {
            
        }
            break;
        case ErrorCodeReceiverIDZero:
        {
            [Common checkProgressHUDShowInAppKeyWindow:@"发送失败，接收方id不能为 0" andImage:nil];
        }
            break;
        default:
            break;
    }
 
}

@end
