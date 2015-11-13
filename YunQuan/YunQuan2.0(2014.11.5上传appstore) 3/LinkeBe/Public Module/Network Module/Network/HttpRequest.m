//
//  HttpRequest.m
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import "HttpRequest.h"
//#import "CmdOperationParser.h"
#import "JSONKit.h"

// 数据返回时需要此锁
static NSRecursiveLock *dataLock = nil;

Class object_getClass(id object);

@implementation HttpRequest

@synthesize httpDelegate;
@synthesize param;

- (id)initWithURL:(NSURL *)newURL delegate:(id)adelegate
{
    if (self = [super initWithURL:newURL]) {
        self.httpDelegate = adelegate;
        if (dataLock == nil) {
            dataLock = [[NSRecursiveLock alloc]init];
        }
        requestClass = object_getClass(adelegate);
    }
    return self;
}

- (void)httpDelegateRequest:(NSString *)data type:(int)type
{
    int ver = 0;
    // 加锁
    [dataLock lock];
    if (data) {
        if (object_getClass(httpDelegate) == requestClass) {
            NSDictionary* jsonDic = [data objectFromJSONString];
            // 委托将数据返回到页面
            if ([httpDelegate respondsToSelector:@selector(didFinishCommand:cmd:withVersion:)] || [httpDelegate respondsToSelector:@selector(didFinishCommand:cmd:withVersion:andParam:)]) {
                [self judgeParamAndCallBackWithDic:jsonDic andType:type andVer:ver];
            }
        }
    } else {
        if (object_getClass(httpDelegate) == requestClass) {
            NSDictionary* jsonDic = [data objectFromJSONString];

            // 委托将数据返回到页面
            [self judgeParamAndCallBackWithDic:jsonDic andType:type andVer:ver];
        }
    }
    // 解锁
    [dataLock unlock];
}

- (void)judgeParamAndCallBackWithDic:(NSDictionary *)dic andType:(int)type andVer:(int)ver
{
    if ([httpDelegate respondsToSelector:@selector(didFinishCommand:cmd:withVersion:)]) {
        [httpDelegate didFinishCommand:dic cmd:type withVersion:ver];
    } else if ([httpDelegate respondsToSelector:@selector(didFinishCommand:cmd:withVersion:andParam:)]) {
        [httpDelegate didFinishCommand:dic cmd:type withVersion:ver andParam:self.param];

    }
    
//    if (self.param != nil) {
//        [httpDelegate didFinishCommand:dic cmd:type withVersion:ver andParam:self.param];
//    } else {
//        [httpDelegate didFinishCommand:dic cmd:type withVersion:ver];
//    }
}

- (void)dealloc
{
    self.httpDelegate = nil;
    self.param = nil;
    
    [super dealloc];
}
@end
