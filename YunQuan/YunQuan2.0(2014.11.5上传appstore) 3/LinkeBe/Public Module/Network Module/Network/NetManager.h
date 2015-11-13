//
//  DataManager.h
//  ASIHttp
//
//  Created by yunlai on 13-5-29.
//  Copyright (c) 2013年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@class CmdOperation;

@interface NetManager : NSObject
{
    CmdOperation *commandOperation;
}

// 单例模式创建实例
+ (NetManager *)sharedManager;

/*  执行请求
 *  url                 域名1
 *  reqdic              url的参数
 *  dataList            当前post的数据
 *  methodName          通信接口
 *  interface           通信接口的枚举标识
 *  callBackDelegate    回调委托
 *  SSL                 是否加密
 *  param
 */
-(void)sendRequestWithEnvironment:(NSString *)url
                bodyUrlDictionary:(NSMutableDictionary *)reqdic
                  bodyUrlDataList:(NSArray *)dataList
                     byMethodName:(NSString *)methodName
                      byInterface:(LinkedBe_WInterface)interface
               byCallBackDelegate:(id)callBackDelegate
                              SSL:(BOOL)isEncrypt
                      requestType:(LinkedBe_RequestType)requestType;

@end
