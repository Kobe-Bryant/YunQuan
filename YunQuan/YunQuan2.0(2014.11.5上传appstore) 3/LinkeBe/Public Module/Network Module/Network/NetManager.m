//
//  DataManager.m
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import "NetManager.h"
#import "CmdOperation.h"
#import "Common.h"
#import "Global.h"
#import "NSObject_extra.h"
#import "PKReachability.h"

@implementation NetManager

- (id)init
{
    self = [super init];
    if (self) {
        commandOperation = [[CmdOperation alloc]init];
        [commandOperation start];
    }
    return self;
}

-(void)checkNetWork{
    //    网络的判断
    PKReachability *reach = [PKReachability reachabilityForInternetConnection];
    if (![reach isReachable]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"当前网络不可用，请稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [alertView release];

        return;
    }
}
// 单例模式创建实例
+ (NetManager *)sharedManager
{
    static NetManager *dataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[self alloc] init];
    });
    return dataManager;
}

// 判断是否联网
-(BOOL)isConnectNetWork{
    BOOL isExistenceNetwork = YES;
    PKReachability *r = [PKReachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
        {
            isExistenceNetwork=NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"当前网络不可用，请稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                [alertView release];
                
            });
        }
            break;
        case ReachableViaWWAN:
        {
            isExistenceNetwork=YES;
            NSLog(@"正在使用3G网络");
        }
            break;
        case ReachableViaWiFi:
        {
            isExistenceNetwork=YES;
            NSLog(@"正在使用wifi网络");
        }
            break;
    }
    return isExistenceNetwork;
}

//发送参数的地方
-(void)sendRequestWithEnvironment:(NSString *)url
                bodyUrlDictionary:(NSMutableDictionary *)reqdic
                  bodyUrlDataList:(NSArray *)dataList
                     byMethodName:(NSString *)methodName
                      byInterface:(LinkedBe_WInterface)interface
               byCallBackDelegate:(id)callBackDelegate
                              SSL:(BOOL)isEncrypt
                      requestType:(LinkedBe_RequestType)requestType{
    //  网络的判断
//    if ([self isConnectNetWork]) {
    NSString *reqstrURL = [self requestURladdress:url methodName:methodName requestUrlDic:reqdic requestUrlDataList:dataList requestType:requestType];
    
    switch (requestType) {
        case LinkedBe_GET: //get 的请求的方式
        {
            [commandOperation addOperationHTTPRequest:[NSURL URLWithString:reqstrURL] type:interface delegate:callBackDelegate withParam:nil];
        }
            break;
        case LinkedBe_POST: //POST 的请求的方式
        {
            if(dataList){
                // 将POST请求添加到队列(支持多图片上传)
                [commandOperation addOperationPostRequest:[NSURL URLWithString:reqstrURL] paramerDic:reqdic dataList:dataList type:interface delegate:callBackDelegate withParam:nil];
            }else{
                [commandOperation addOperationPostRequest:[NSURL URLWithString:reqstrURL] paramerDic:reqdic type:interface delegate:callBackDelegate withParam:nil];
            }
        }
            break;
        case LinkedBe_PUT: //PUT 的请求的方式
        {
            [commandOperation addOperationPutRequest:[NSURL URLWithString:reqstrURL] paramerDic:reqdic type:interface delegate:callBackDelegate withParam:nil];
        }
            break;
        case LinkedBe_DELETE: //DELETE 的请求的方式
        {
            [commandOperation addOperationDeleteRequest:[NSURL URLWithString:reqstrURL] paramerDic:reqdic type:interface delegate:callBackDelegate withParam:nil];
        }
            break;
        default:
            break;
    }
//    }
}

-(NSString *)requestURladdress:(NSString *)urlString methodName:(NSString *)methodName requestUrlDic:(NSMutableDictionary *)reqDic requestUrlDataList:(NSArray *)reqArray requestType:(LinkedBe_RequestType)requestType{
    NSString *requstString;
    switch (requestType) {
        case LinkedBe_GET: //get 的请求的方式
        {
            if (reqDic && [reqDic allKeys].count) {
                requstString = [[NSString stringWithFormat:@"%@%@?",urlString,methodName] stringByAppendingString:[self requestURladdress:reqDic]];
            }else{
                requstString = [NSString stringWithFormat:@"%@%@",urlString,methodName];
            }
        }
            break;
        case LinkedBe_POST: //POST 的请求的方式
        {
            requstString = [NSString stringWithFormat:@"%@%@",urlString,methodName];
        }
            break;
        case LinkedBe_PUT: //PUT 的请求的方式
        {
            requstString = [NSString stringWithFormat:@"%@%@",urlString,methodName];
        }
            break;
        case LinkedBe_DELETE: //DELETE 的请求的方式
        {
            requstString = [NSString stringWithFormat:@"%@%@",urlString,methodName];
        }
            break;
        default:
            break;
    }
    return requstString;
}

- (void)dealloc
{
    [commandOperation cancel];
    [commandOperation release], commandOperation = nil;
	[super dealloc];
}
@end
