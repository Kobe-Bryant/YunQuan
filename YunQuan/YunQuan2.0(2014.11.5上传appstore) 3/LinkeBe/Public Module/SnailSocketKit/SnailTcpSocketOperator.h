//
//  SnailTcpSocketOperator.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailTcpSocketOperator : NSObject

+ (SnailTcpSocketOperator *)shareOperator;
//连接服务器
- (BOOL)connectToHost;
//断开服务器
- (void)disConnectHost;
//发送消息
- (void)sendMessage:(NSData *)data withTimeout:(NSTimeInterval)timeout;
//判断是否已经连接
- (BOOL)isConnected;
@end
