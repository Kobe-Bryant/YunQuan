//
//  SnailNetWorkManager.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailNetWorkManager.h"
#import "SnailRequestPostObject.h"
#import "CmdOperation.h"
#import "Common.h"
#import "Global.h"
#import "NSObject_extra.h"

@interface SnailNetWorkManager ()
{
    
}

@property (nonatomic, retain) CmdOperation *cmdOperation;

@end

@implementation SnailNetWorkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cmdOperation = [[[CmdOperation alloc]init]autorelease];
        [self.cmdOperation start];
    }
    return self;
}

+ (SnailNetWorkManager *)shareManager
{
    static SnailNetWorkManager *dataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[self alloc] init];
    });
    return dataManager;
}

- (void)sendHttpRequest:(SnailRequestObject *)requestObject fromDelegate:(id)delegate andParam:(NSMutableDictionary *)parameter;
{
    NSString * requestStr = [self requestURladdressWithRequest:requestObject];
    NSURL * url = [NSURL URLWithString:requestStr];
    
    NSLog(@"Snail Request UrlStr : %@",requestStr);
    
    switch (requestObject.requestType) {
        case LinkedBe_POST:
        {
            SnailRequestPostObject * postRequest = (SnailRequestPostObject *)requestObject;
            
            if(postRequest.postDataArr != nil){
                //                发送图片和音频的文件系统
                [self.cmdOperation addOperationPostRequest:url paramerDic:requestObject.requestParam dataList:postRequest.postDataArr type:requestObject.command delegate:delegate withParam:parameter];
                
            }else if(postRequest.postData) {
                //                post当前的字典里面的东西
                [self.cmdOperation addOperationPostRequest:url data:postRequest.postData type:requestObject.command delegate:delegate withParam:parameter];
            }
        }
            break;
        case LinkedBe_GET:
        {
            //发送get请求
            [self.cmdOperation addOperationHTTPRequest:url type:requestObject.command delegate:delegate withParam:parameter];
        }
            break;
        case LinkedBe_PUT:
        {
            //发送put求求
            [self.cmdOperation addOperationPutRequest:url paramerDic:requestObject.requestParam type:requestObject.command delegate:delegate withParam:parameter];
        }
            break;
        default:
            break;
    }
}

-(NSString *)requestURladdressWithRequest:(SnailRequestObject *)requestObject
{
    NSString * typeSignStr = nil;
    NSString *reqstrURLString = nil;
    
    switch (requestObject.requestType) {
        case LinkedBe_POST:
        case LinkedBe_PUT:
        {
            typeSignStr = @"";
            reqstrURLString = [NSString stringWithFormat:@"%@%@%@",HTTPURLPREFIX,requestObject.requestInterface,typeSignStr];
        }
            break;
        case LinkedBe_GET:
        {
            typeSignStr = @"?";
            reqstrURLString = [NSString stringWithFormat:@"%@%@%@",HTTPURLPREFIX,requestObject.requestInterface,typeSignStr];
            
            NSMutableDictionary *addressDicionary = requestObject.requestParam;
            NSArray *keyArray = [addressDicionary allKeys];
            for (int i = 0; i< [keyArray count]; i++) {
                NSString *tempString;
                if (i == 0) {
                    tempString = [NSString stringWithFormat:@"%@=%@",[keyArray objectAtIndex:i],[addressDicionary objectForKey:[keyArray objectAtIndex:i]]];
                }else{
                    tempString = [NSString stringWithFormat:@"%@=%@",[@"&"stringByAppendingString:[keyArray objectAtIndex:i]],[addressDicionary objectForKey:[keyArray objectAtIndex:i]]];
                }
                reqstrURLString = [reqstrURLString stringByAppendingString:tempString];
            }
        }
            
        default:
            break;
    }
  
    return reqstrURLString;
}

@end
