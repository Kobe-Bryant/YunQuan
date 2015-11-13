//
//  CommandOperation.m
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import "CmdOperation.h"
#import "HttpRequest.h"
#import "ASINetworkQueue.h"
#import "Global.h"
#import "JSONKit.h"
#import "NSObject+SBJson.h"
#import "UserModel.h"
#import "ASIHTTPRequest.h"
#import "LoginSendClientMessage.h"
#import "MessageData.h"
#import "SnailSystemiMOperator.h"
#import "SnailSocketManager.h"
#import "AppDelegate.h"
#import "NSObject_extra.h"

@implementation CmdOperation

@synthesize queue;

// 初始化 ASINetworkQueue
- (id)init
{
    if (self = [super init]) {
        queue = [[ASINetworkQueue alloc]init];
        [queue setDelegate:self];
        [queue setRequestDidFailSelector:@selector(requestDidFail:)];
        [queue setRequestDidFinishSelector:@selector(requestDidFinish:)];
        [queue setShouldCancelAllRequestsOnFailure:NO];
        [queue setShowAccurateProgress:YES];
    }
    return self;
}

- (BOOL)isRunning
{
    return ![queue isSuspended];
}

// 开始
- (void)start
{
    if ([queue isSuspended]) {
        [queue go];
    }
}

// 暂停
- (void)pause
{
    [queue setSuspended:YES];
}

// 取消暂停
- (void)resume
{
    [queue setSuspended:NO];
}

// 取消队列
- (void)cancel
{
    [queue cancelAllOperations];
}

// 将http请求添加到队列
- (void)addOperationHTTPRequest:(NSURL *)url type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param
{
    HttpRequest *request = [[HttpRequest alloc] initWithURL:url delegate:adelegate];
    LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
    if ([loginSendClient authorizationReturn]) {
        [request addRequestHeader:@"Authorization" value:[loginSendClient authorizationReturn]];
    }
    [self setUserInfo:request type:commonID url:[url absoluteString]];
    [request setParam:param];
    [queue addOperation:request];
    [request release];
}

// 将POST请求添加到队列
- (void)addOperationPostRequest:(NSURL *)url data:(NSData *)imageData type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param
{
    HttpRequest *request = [[HttpRequest alloc] initWithURL:url delegate:adelegate];
    LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
    [request setStringEncoding:NSUTF8StringEncoding];

    request.requestMethod = @"POST";
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    [self setUserInfo:request type:commonID url:[url absoluteString]];
    
    [request setParam:param];
    [request setPostValue:@"SinglePost" forKey:@"PostValue"];
    
    if ([loginSendClient authorizationReturn]) {
        [request addRequestHeader:@"Authorization" value:[loginSendClient authorizationReturn]];
    }
    
    NSString * contentType = @"multipart/form-data";
    NSString * fileName = nil;
    
    MessageData * messageData= [param objectForKey:@"msgObject"];
    if (messageData.sessionData.objtype) {
        switch (messageData.sessionData.objtype) {
            case DataMessageTypePicture:
            {
                fileName = @"photos.jpg";
            }
                break;
            case DataMessageTypeVoice:
            {
                fileName = @"audios.amr";
            }
                break;
            default:
                break;
        }
    }else{
        fileName = @"photos.jpg";
    }
   
    [request addData:imageData withFileName:fileName andContentType:contentType forKey:@"file"];
    [queue addOperation:request];
    [request release];
}

// 将POST请求添加到队列(支持多图片上传)
-(void)addOperationPostRequest:(NSURL *)url paramerDic:(NSDictionary *)paramerDic dataList:(NSArray *)dataList type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param
{
    HttpRequest *request = [[HttpRequest alloc] initWithURL:url delegate:adelegate];
    LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
    
    if ([loginSendClient authorizationReturn]) {
        [request addRequestHeader:@"Authorization" value:[loginSendClient authorizationReturn]];
    }
    
    NSArray *keyArray = [paramerDic allKeys];
    for (int i = 0; i< [keyArray count]; i++) {
        [request setPostValue:[paramerDic objectForKey:[keyArray objectAtIndex:i]] forKey:[keyArray objectAtIndex:i]];
    }
    [request setStringEncoding:NSUTF8StringEncoding];
    request.requestMethod = @"POST";
    [self setUserInfo:request type:commonID url:[url absoluteString]];
    [request setParam:param];
    
    if(dataList.count > 0)
    {
        [request setPostFormat:ASIMultipartFormDataPostFormat];
        for (NSData *data in dataList)
        {
            NSInteger index = [dataList indexOfObject:data];
            [request addData:data withFileName:[NSString stringWithFormat:@"%d.jpg",index] andContentType:@"image/jpeg" forKey:[NSString stringWithFormat:@"files[%d]",index]];
        }
    }
    [queue addOperation:request];
    [request release];
}

// 设置ASIHTTPRequest userInfo
- (void)setUserInfo:(HttpRequest *)request type:(int)commonID url:(NSString *)str
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:commonID], RequestTypeKey,
                          str, @"url", nil];
    [request setUserInfo:dict];
}

//add vincent
- (void)addOperationPostRequest:(NSURL *)url paramerDic:(NSDictionary *)paramerDic type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param{
    HttpRequest *request = [[HttpRequest alloc] initWithURL:url delegate:adelegate];
    LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
    NSString *authString = [loginSendClient authorizationReturn];
    if (authString) {
        [request addRequestHeader:@"Authorization" value:authString];
    }
    [self setUserInfo:request type:commonID url:[url absoluteString]];
    NSArray *keyArray = [paramerDic allKeys];
    for (int i = 0; i< [keyArray count]; i++) {
        [request setPostValue:[paramerDic objectForKey:[keyArray objectAtIndex:i]] forKey:[keyArray objectAtIndex:i]];
    }
    [request setStringEncoding:NSUTF8StringEncoding];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setDidFinishSelector : @selector (requestDidFinish:)];
    [request setDidFailSelector : @selector (requestDidFail:)];
    [request startAsynchronous];
}

// put的方法的发送 和post差不多的类型
- (void)addOperationPutRequest:(NSURL *)url paramerDic:(NSDictionary *)paramerDic type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param{
    HttpRequest *request = [[HttpRequest alloc] initWithURL:url delegate:adelegate];
    LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
    if ([loginSendClient authorizationReturn]) {
        [request addRequestHeader:@"Authorization" value:[loginSendClient authorizationReturn]];
    }
    [self setUserInfo:request type:commonID url:[url absoluteString]];
    NSArray *keyArray = [paramerDic allKeys];
    for (int i = 0; i< [keyArray count]; i++) {
        [request setPostValue:[paramerDic objectForKey:[keyArray objectAtIndex:i]] forKey:[keyArray objectAtIndex:i]];
    }
    [request setStringEncoding:NSUTF8StringEncoding];
    [request setRequestMethod:@"PUT"];
    [request setDelegate:self];
    [request setDidFinishSelector : @selector (requestDidFinish:)];
    [request setDidFailSelector : @selector (requestDidFail:)];
    [request startAsynchronous];
}

// delete的方法的发送
- (void)addOperationDeleteRequest:(NSURL *)url paramerDic:(NSDictionary *)paramerDic type:(int)commonID delegate:(id)adelegate withParam:(NSMutableDictionary *)param{
    HttpRequest *request = [[HttpRequest alloc] initWithURL:url delegate:adelegate];
    LoginSendClientMessage *loginSendClient = [[LoginSendClientMessage alloc] init];
    
    if ([loginSendClient authorizationReturn]) {
        [request addRequestHeader:@"Authorization" value:[loginSendClient authorizationReturn]];
    }
    [self setUserInfo:request type:commonID url:[url absoluteString]];
    NSArray *keyArray = [paramerDic allKeys];
    for (int i = 0; i< [keyArray count]; i++) {
        [request setPostValue:[paramerDic objectForKey:[keyArray objectAtIndex:i]] forKey:[keyArray objectAtIndex:i]];
    }

    [request buildPostBody];
    //构造请求
    [request setRequestMethod:@"DELETE"];
    //设置代理
    [request setDelegate:self];
    [request setDidFinishSelector : @selector (requestDidFinish:)];
    [request setDidFailSelector : @selector (requestDidFail:)];
    //异步传输
    [request startAsynchronous];
}

// 联网失败后  信息反馈
- (void)requestDidFail:(HttpRequest *)request
{
    NSLog(@"responseStatusCode %d",request.responseStatusCode);
    
    int commonid = [[[request userInfo] objectForKey:RequestTypeKey] intValue];
    NSLog(@"requestDidFail commonid = %d",commonid);

    //    if (request.responseStatusCode == 401) {
//        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"登录失败"];
//        
//        [SnailSocketManager breakConnect];
//        
//        [[UserModel shareUser] clearUserInfo];
//        
//        AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//        [appdelegate initGuidePageVc];
//        
//        return;
//    }
    
    NSDictionary * faildJson = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInt:RequestErrorCodeFailed],@"errcode", nil];
    NSString * faildJsonStr = [faildJson JSONRepresentation];
    [request httpDelegateRequest:faildJsonStr type:commonid];
}

// 联网成功后  返回数据
- (void)requestDidFinish:(HttpRequest *)request
{
    // 得到请求的commonid
    int commonid = [[[request userInfo] objectForKey:RequestTypeKey] intValue];
    
    NSLog(@"result.url %@",request.url);
    // 得到请求的数据
    NSString *resultStr = [request responseString];
    NSLog(@"resultStr %@",resultStr);
    
    NSLog(@"responseStatusCode %d",request.responseStatusCode);
    
    if(request.responseStatusCode > 400 && request.responseStatusCode != 408){
        [Common checkProgressHUDShowInAppKeyWindow:@"网络连接失败，请重试" andImage:[UIImage imageNamed:@"ico_group_wrong.png"]];
    }else if (request.responseStatusCode == 408){
        [Common checkProgressHUDShowInAppKeyWindow:@"网络连接不太顺畅,请求超时,请重试" andImage:[UIImage imageNamed:@"ico_group_wrong.png"]];
    }else if(request.responseStatusCode == 200){
//        在具体的方法里面判断老是出问题，一怒下放到这个里面了，不好意思，到时候在优化。add  vincent 退出im的登录
        if (commonid==LinkedBe_Member_LoginOut) {
            if ([[[resultStr objectFromJSONString] objectForKey:@"errcode"] integerValue]==0) {
                BOOL isConnected = [SnailSocketManager isConnected];
                if (isConnected) {
                    SnailSystemiMOperator *systemOut = [[SnailSystemiMOperator alloc] init];
                    [systemOut loginIMServerOut];
                }else{
                    [SnailSocketManager breakConnect];
                    
                    [[UserModel shareUser] clearUserInfo];

                    AppDelegate* appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appdelegate initGuidePageVc];
                }
             
            }else{
                [Common checkProgressHUDShowInAppKeyWindow:@"退出登录失败" andImage:[UIImage imageNamed:@"ico_me_wrong.png"]];
            }
        }else{
            [request httpDelegateRequest:resultStr type:commonid];
        }
    }
    
}

@end
