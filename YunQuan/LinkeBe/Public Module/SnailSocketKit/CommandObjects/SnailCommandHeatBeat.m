//
//  SnailHeartBeatAckCommand.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandHeartBeat.h"
#import "SnailSocketManager.h"
#import "SnailCommandFactory.h"


@implementation SnailCommandHeartBeat

- (void)handleCommandData
{
    NSTimeInterval heartBeatDistant = [[self.bodyDic objectForKey:@"step"]intValue];
    [NSTimer scheduledTimerWithTimeInterval:heartBeatDistant target:self selector:@selector(keepSendHeartBeatCommand) userInfo:nil repeats:NO];
}

- (void)keepSendHeartBeatCommand
{
    NSLog(@"再次发送心跳包");
    SnailCommandObject * heatBeat = [SnailCommandFactory commandObjectWithCommand:CMD_USER_HEARTBEAT andBodyDic:nil andReceiverID:0];
    [SnailSocketManager sendCommandObject:heatBeat];
}

@end
