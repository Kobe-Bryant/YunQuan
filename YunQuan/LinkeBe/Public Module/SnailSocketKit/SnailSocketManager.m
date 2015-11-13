//
//  SnailSocketManager.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailSocketManager.h"
#import "SnailTcpSocketOperator.h"
#import "SnailCommandFactory.h"

@implementation SnailSocketManager

+ (void)sendCommandObject:(SnailCommandObject *)commandObj
{
    [[SnailTcpSocketOperator shareOperator]sendMessage:[commandObj data] withTimeout:-1];
}

+ (void)breakConnect
{
    [[SnailTcpSocketOperator shareOperator]disConnectHost];
}

+ (void)recieveSocketData:(NSData *)data
{
    SnailCommandObject * receiveCommand = [SnailCommandFactory commandObjectWithData:data];
    [receiveCommand handleCommandData];
}

+ (BOOL)isConnected
{
    return [[SnailTcpSocketOperator shareOperator]isConnected];
}

+ (void)connectToServer
{
    [[SnailTcpSocketOperator shareOperator]connectToHost];
}

@end
