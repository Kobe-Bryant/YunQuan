
//
//  SystemApnsLoginMessageData.m
//  LinkeBe
//
//  Created by yunlai on 14-9-26.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SystemApnsLoginMessageData.h"
#import "LinkedBeHttpRequest.h"
#import "upgrade_model.h"
#import "secret_message_model.h"
#import "Global.h"
#import "UserModel.h"
#import "SecretarySingleton.h"
#import "OrgSingleton.h"
#import "SecretaryOrgInfoTable_model.h"

@implementation SystemApnsLoginMessageData

-(void) accessSystemApnsMessageData:(NSMutableDictionary*) apnsMessageDic{
    [[LinkedBeHttpRequest shareInstance] requestSystemAPNSDelegate:self parameterDictionary:apnsMessageDic parameterArray:nil parameterString:nil];
}


//请求回调
#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
    NSMutableArray *systemApnsArray = nil;
    switch (commandid) {
            case LinkedBe_System_Apns:
            {
                NSDictionary * resultDic = jsonDic;
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
                if (resultDic) {
                    //创建模型
                    upgrade_model* upMod = [[upgrade_model alloc] init];
                    [upMod deleteDBdata];
                    NSDictionary* upgDic = [resultDic objectForKey:@"upgrade"];
                    NSDictionary* aDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [upgDic objectForKey:@"ver"],@"ver",
                                          [upgDic objectForKey:@"url"],@"url",
                                          [upgDic objectForKey:@"score_url"],@"score_url",
                                          [upgDic objectForKey:@"remark"],@"remark",
                                          nil];
                    [upMod insertDB:aDic];
                    RELEASE_SAFE(upMod);
                    
                    secret_message_model* secMsgMod = [[secret_message_model alloc] init];
                    NSDictionary* secDic = [resultDic objectForKey:@"secretary"];
                    NSDictionary* secModDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [secDic objectForKey:@"userId"],@"userId",
                                               [secDic objectForKey:@"headerImg"],@"headerImg",
                                               [secDic objectForKey:@"orgname"],@"orgname",
                                               nil];
                    
                    NSMutableDictionary * specialObjectDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[secDic objectForKey:@"userId"],@"uid",
                                                              [secDic objectForKey:@"orgname"],@"realname",
                                                              [NSNumber numberWithInt:SpecialContectSecretary],@"type",
                                                              [secDic objectForKey:@"headerImg"],@"portrait",
                                                              nil];
                    [SecretaryOrgInfoTable_model insertOrUpdateInfoWithDic:specialObjectDic];
                    
                    [UserModel shareUser].secretInfo = secModDic;
                    [SecretarySingleton shareSecretary].secretaryID = [[secDic objectForKey:@"userId"]longLongValue];
                    [SecretarySingleton shareSecretary].secretaryName = [secDic objectForKey:@"orgname"];
                    [SecretarySingleton shareSecretary].secretaryPortrait = [secDic objectForKey:@"headerImg"];
                    
                    
                    //各类型小秘书文本
                    NSArray* secMsgModArr = [secMsgMod getList];
                    if (secMsgModArr.count) {
                        [secMsgMod deleteDBdata];
                    }

                    NSArray* secMsgArr = [resultDic objectForKey:@"secretaryMessage"];
                    for (NSDictionary* dic in secMsgArr) {
                        NSDictionary* smDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [dic objectForKey:@"type"],@"type",
                                               [dic objectForKey:@"message"],@"message",
                                               nil];
                        [secMsgMod insertDB:smDic];
                    }
                    RELEASE_SAFE(secMsgMod);
                }

                [pool release];

                //设备令牌
                upgrade_model* upgradeMod = [[upgrade_model alloc] init];
                systemApnsArray = [upgradeMod getList];
                [upgradeMod release];
            }
                break;
                default:
                break;
        }

    [_delegate getSystemApnsLoginMessageHttpCallBack:systemApnsArray interface:LinkedBe_System_Apns];
}

@end
