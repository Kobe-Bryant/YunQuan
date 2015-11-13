//
//  SnailLoginCommandObject.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandLogin.h"
#import "SnailCommandFactory.h"
#import "SnailSocketManager.h"

@implementation SnailCommandLogin

- (instancetype)initWithData:(NSData *)data
{
    self = [super initWithData:data];
    if (self) {
    }
    return self;
}

- (void)handleCommandData
{
    //处理业务逻辑发送登陆成功通知
    [[NSNotificationCenter defaultCenter]postNotificationName:IMLoginSuccess object:nil];
    //发送心跳
    SnailCommandObject * heatBeatCommand = [SnailCommandFactory commandObjectWithCommand:CMD_USER_HEARTBEAT andBodyDic:nil andReceiverID:0];
    heatBeatCommand.receiverID = 0;
    [SnailSocketManager sendCommandObject:heatBeatCommand];
}

@end
