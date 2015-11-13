//
//  CommandOperation.h
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RequestTypeKey @"commonid"

@class ASINetworkQueue;

@interface CmdOperation : NSObject
{
    ASINetworkQueue *queue;
}

@property (retain, nonatomic) ASINetworkQueue *queue;

- (BOOL)isRunning;
// 开始
- (void)start;
// 暂停
- (void)pause;
// 取消暂停
- (void)resume;
// 取消队列
- (void)cancel;

// 将http请求添加到队列
- (void)addOperationHTTPRequest:(NSURL *)url type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param;

// 将POST请求添加到队列
- (void)addOperationPostRequest:(NSURL *)url data:(NSData *)imageData type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param;

// 将POST请求添加到队列(支持多图片上传)
- (void)addOperationPostRequest:(NSURL *)url paramerDic:(NSDictionary *)paramerDic dataList:(NSArray *)dataList type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param;

// 将当前的字典转换位post的类型传递过去
- (void)addOperationPostRequest:(NSURL *)url paramerDic:(NSDictionary *)paramerDic type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param;

// put的方法的发送
- (void)addOperationPutRequest:(NSURL *)url paramerDic:(NSDictionary *)paramerDic type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param;
// delete的方法的发送
- (void)addOperationDeleteRequest:(NSURL *)url paramerDic:(NSDictionary *)paramerDic type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param;
@end
