//
//  SnailTcpSocketOperator.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailTcpSocketOperator.h"
#import "AsyncSocket.h"
#import "SnailSocketManager.h"
#import "SnailSystemiMOperator.h"
#import "LoginSendClientMessage.h"

@interface SnailTcpSocketOperator ()
{
    
}

@property (nonatomic, retain) AsyncSocket *asynchronousSocket;

@property (nonatomic, retain) NSMutableData *streamDataCache;

@end


//流操作唯一标示 读
static int writeTag = 0;
//唯一标示 写
static int readTag = 0;

@implementation SnailTcpSocketOperator

+ (SnailTcpSocketOperator *)shareOperator
{
    static SnailTcpSocketOperator * m_SnailTcpOperator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_SnailTcpOperator = [[SnailTcpSocketOperator alloc]init];
        m_SnailTcpOperator.streamDataCache = [NSMutableData data];
        
        AsyncSocket * tempSocket = [[AsyncSocket alloc]initWithDelegate:m_SnailTcpOperator];
        m_SnailTcpOperator.asynchronousSocket = tempSocket;
        RELEASE_SAFE(tempSocket);
    });
    return m_SnailTcpOperator;
}

- (BOOL)isConnected
{
    return self.asynchronousSocket.isConnected;
}

- (BOOL)connectToHost {
    // 连接服务器
    if (![self.asynchronousSocket isConnected]) {
        NSError * error = nil;
        if ([self.asynchronousSocket isDisconnected]) {
            [self.asynchronousSocket connectToHost:SOCKETIP onPort:SOCKETPORT error:&error];
        }
        if (error != nil) {
            [Common checkProgressHUDShowInAppKeyWindow:[NSString stringWithFormat:@"Socket 链接异常 %@",error] andImage:nil];
            return NO;
        }
    } else {
        NSLog(@"已经和服务器连接");
    }
    return YES;
}

- (void)disConnectHost {
    [self.asynchronousSocket disconnect];
}

//写入流数据
- (void)sendMessage:(NSData *)data withTimeout:(NSTimeInterval)timeout
{
    if ([self isConnected]) {
        [self.asynchronousSocket writeData:data withTimeout:timeout tag:++writeTag];
    }
}

#pragma mark - AsyncSocketDelegate
/**
 *   链接相关
 *
 */

// 成功连接后自动回调
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [sock readDataWithTimeout:-1 tag:++readTag];
    NSLog(@"=====Soket 已经连接到服务器:%@ %hu",host,port);
    
    SnailSystemiMOperator * loginManager =[[SnailSystemiMOperator alloc]init];
    [loginManager loginIMServer];
    RELEASE_SAFE(loginManager);
}

// 接收到了一个新的socket连接 自动回调
// 接收到了新的连接  那么释放老的连接
-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"=====Socket DidacceptNewSocket %@",newSocket);
}

- (void)onSocketDidSecure:(AsyncSocket *)sock{
    NSLog(@"=====Socket Secure ");
}

/**
 *  写数据相关
 *
 */
// 写数据成功 自动回调
-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"=====Socket 写数据成功 %ld",tag);
    // 继续监听
    [sock readDataWithTimeout:-1 tag:++readTag];
}

//写入部分数据 回调
- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag{
    NSLog(@"=====Soket write partial data length %d",partialLength);
}

//写数据的过程中遇见 timeout
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length
{
    
    NSLog(@"=====Soket ShouldWrite tag%ld elapsed%f length%d",tag,elapsed,length);
    return -1;
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err{
    NSLog(@"======Socket Will disconnect with:%@",err);
    //    [Common checkProgressHUD:[NSString stringWithFormat:@"======Socket Will disconnect with %@",err ] andImage:nil showInView:APPD.keyWindow];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock{
    
    NSLog(@"======Socket DidDisconnected");
}

/**
 *  读数据相关
 *
 */

// 客户端接收到了数据
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"=====Soket 收到消息");
    
    NSMutableArray *packgeArr = [[NSMutableArray alloc]init];
    // Incase the data is not complate so append data to insure it's complated
    [self.streamDataCache appendData:data];
    [self getComplateDataToArray:packgeArr];
    
    if (packgeArr.count > 0) {
        for (NSData * temp in packgeArr) {
            [SnailSocketManager recieveSocketData:temp];
        }
    }
    RELEASE_SAFE(packgeArr);
    // 继续监听
    [sock readDataWithTimeout:-1 tag:tag];
}

//完整包拼接逻辑
- (void)getComplateDataToArray:(NSMutableArray *)arr
{
    const void * byte = (const void *) [self.streamDataCache bytes];
    if (self.streamDataCache.length >= 8) {
        UInt32* dwlen = (UInt32*)&byte[4];
        int len = ntohl(*dwlen);
        if (self.streamDataCache.length < len) {
            return;
        }else{
            NSData* packageData = [NSData dataWithData:[self.streamDataCache subdataWithRange:NSMakeRange(0, len)]];
            [arr addObject:packageData];
            if (len == self.streamDataCache.length) {
                self.streamDataCache = [[[NSData data] mutableCopy]autorelease];
            }else{
                self.streamDataCache = [[[NSData dataWithData:[self.streamDataCache subdataWithRange:NSMakeRange(len, self.streamDataCache.length - len)]] mutableCopy]autorelease];
                [self getComplateDataToArray:arr];
            }
        }
    }else{
        return;
    }
}


//读数据过程中遇见 timeout
- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length
{
    NSLog(@"=====Soket read should time out elapsed %f doneByteLength %d",elapsed,length);
    return -1;
}

// 客户端读取数据
- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"=====Socket did read partial length %d",partialLength);
}

#pragma mark - Dealloc
- (void)dealloc
{
    self.asynchronousSocket = nil;
    self.streamDataCache = nil;
    [super dealloc];
}

@end
