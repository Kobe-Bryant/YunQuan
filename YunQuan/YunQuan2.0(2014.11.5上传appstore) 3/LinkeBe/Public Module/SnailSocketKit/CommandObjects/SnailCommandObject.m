//
//  SnailCommandObject.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandObject.h"
#import "SBJson.h"
#import "SnailSokcetMacro.h"
#import "NSData+SocketAddiction.h"

@implementation SnailCommandObject

- (instancetype)initWithData:(NSData *)data
{
    self = [self init];
    if (self) {
        self.serialNumber = [data rw_int16AtOffset:8];
        self.command = [data rw_int16AtOffset:10];
        self.senderID = [data rw_int64AtOffset:12];
        self.receiverID = [data rw_int64AtOffset:20];
        
        size_t wholeLength;
        NSString * bodyJsonStr = [data rw_stringAtOffset:32 bytesRead:&wholeLength];
        NSDictionary * bodyDic = [bodyJsonStr JSONValue];
        self.bodyDic = bodyDic;
    }
    return self;
}

- (NSData *)data
{
    NSString * bodyJsonStr = [self.bodyDic JSONRepresentation];
    NSData * bodyData = [bodyJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    int wholeLenght = bodyData.length + 32;
    
    NSMutableData * wholeData = [[NSMutableData alloc]init];
    //将data的每个字节进行相应的赋值
    //版本号拼接
    [wholeData rw_appendInt32:SoketPacketVersion];
    //整体包长度拼接
    [wholeData rw_appendInt32:wholeLenght];
    //包序列号拼接
    [wholeData rw_appendInt16:self.serialNumber];
    //操作码拼接
    [wholeData rw_appendInt16:self.command];
    //发送方ID 拼接
    [wholeData rw_appendInt64:self.senderID];
    //接收方ID 拼接
    [wholeData rw_appendInt64:self.receiverID];
    //扩展字节 拼接
    [wholeData rw_appendInt32:EXTEND_NUM];
    //拼接包体
    [wholeData appendData:bodyData];

    return [wholeData autorelease];
}

@end
