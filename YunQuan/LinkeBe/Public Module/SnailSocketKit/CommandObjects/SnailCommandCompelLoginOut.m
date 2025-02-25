//
//  SnailCommandCompelLoginOutObject.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandCompelLoginOut.h"
#import "MyselfMessageManager.h"
#import "NSObject_extra.h"
#import "SnailSystemiMOperator.h"
#import "LinkedBeHttpRequest.h"
#import "SnailRequestPostObject.h"
#import "SnailNetWorkManager.h"
#import "NetManager.h"
#import "SnailRequestGet.h"
#import "SnailSocketManager.h"

@implementation SnailCommandCompelLoginOut

- (void)handleCommandData
{

    //login out method
    [self confirmQuit];
    
//    add vincent  被迫下线
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"您的帐号在其它设备登录，您被迫下线，请重新登录。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    RELEASE_SAFE(alertView);
}

-(void)confirmQuit{
    if ([Common connectedToNetwork]) {
        NSMutableDictionary *loginOutDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"type",[UserModel shareUser].user_id,@"userId",nil];

        NSString *methodName = MYSELF_MEMBER_LOGINOUT_URL;
        SnailRequestGet * getRequest = [[SnailRequestGet alloc]init];
        getRequest.requestInterface = methodName;
        getRequest.command = LinkedBe_Member_LoginOut;
        getRequest.requestParam = loginOutDic;
        [[SnailNetWorkManager shareManager] sendHttpRequest:getRequest fromDelegate:self andParam:nil];
        RELEASE_SAFE(getRequest);
        
    }else{
        [self alertWithFistButton:@"确定" SencodButton:nil Message:@"网络不给力呀，请稍后重试"];
    }
}

//退出im的服务器
-(void)logoutSend{
    SnailSystemiMOperator *systemOut = [[SnailSystemiMOperator alloc] init];
    [systemOut loginIMServerOut];
    RELEASE_SAFE(systemOut);
}

#pragma mark - HttpRequestDelegate
- (void)didFinishCommand:(NSDictionary *)jsonDic cmd:(LinkedBe_WInterface)commandid withVersion:(int)ver andParam:(NSMutableDictionary *)param
{
    switch (commandid) {
        case LinkedBe_Member_LoginOut:
        {
//            if ([[jsonDic objectForKey:@"errcode"] integerValue]==0) {
//                
////                [self logoutSend]; //退出im服务器
//                
//            }else{
//                [Common checkProgressHUDShowInAppKeyWindow:@"退出登录失败" andImage:[UIImage imageNamed:@"ico_me_wrong.png"]];
//            }
        }
            break;
        default:
            break;
    }
}

@end
