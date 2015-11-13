//
//  SnailContactCommandObject.m
//  LinkeBe
//
//  Created by Dream on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandTCAddMemberACK.h"
#import "SnailSocketManager.h"
#import "SnailCommandFactory.h"
#import "TempChatManager.h"

#import "DynamicIMManager.h"

typedef enum {
    ErrorCodeSuccess = 0,
    ErrorCodeFaild = 1,
}ErrorCode;

@implementation SnailCommandTCAddMemberACK

- (void)handleCommandData {
    NSLog(@"创建临时会话");
    ErrorCode recode = [[self.bodyDic objectForKey:@"rcode"]intValue];
    switch (recode) {
        case ErrorCodeSuccess:
        {            
//            [[DynamicIMManager shareManager] receiveAddToTempContact:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                                      [self.bodyDic objectForKey:@"rcode"],@"rcode",
//                                                                      [self.bodyDic objectForKey:@"gid"],@"circleId",
//                                                                      nil]];
            
            
            //获取临时会话详情
            [[TempChatManager shareManager]createOrAddMemberAckWithDic:self.bodyDic andDataLocalID:self.serialNumber];
            
        }
            break;
        case ErrorCodeFaild:
        {
            
        }
            break;
        default:
            break;
    }

    
}

@end
