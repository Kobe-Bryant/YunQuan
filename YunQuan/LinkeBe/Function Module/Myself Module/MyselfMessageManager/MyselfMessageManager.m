//
//  MyselfMessageManager.m
//  LinkeBe
//
//  Created by yunlai on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MyselfMessageManager.h"
#import "LinkedBeHttpRequest.h"
#import "MyselfDataProcess.h"

#import "message_push_model.h"

@implementation MyselfMessageManager

//请求我的个人资料
-(void) accessMyselfMessageData:(NSMutableDictionary*) loginDic{
    [[LinkedBeHttpRequest shareInstance] requestMyself:self parameterDictionary:loginDic parameterArray:nil requestType:LinkedBe_GET];
}

//退出登录
-(void) accessLoginOutMessageData:(NSMutableDictionary*) loginOutDic{
    [[LinkedBeHttpRequest shareInstance] requestLoginOut:self parameterDictionary:loginOutDic parameterArray:nil requestType:LinkedBe_GET];
}

//请求与我相关的数据
-(void) accessRelevantMeData:(NSMutableDictionary*) relevantMeDic{
    [[LinkedBeHttpRequest shareInstance] requestRelevantMe:self parameterDictionary:relevantMeDic parameterArray:nil requestType:LinkedBe_GET];
}

//修改资料
-(void) accessUpdateUserInfoData:(NSMutableDictionary *) updateDic{
    [[LinkedBeHttpRequest shareInstance] requestUpdateUserInfo:self parameterDictionary:updateDic parameterArray:nil requestType:LinkedBe_PUT];
}

//上传图片
-(void) accessUploadImage:(NSMutableDictionary *)updateDic parameterArray:(NSArray *)parameterArray{
    [[LinkedBeHttpRequest shareInstance] requestUploadImage:self parameterDictionary:updateDic parameterArray:parameterArray requestType:LinkedBe_POST];
}

//上传用户图像
-(void)accessUploadUserIcon:(NSMutableDictionary *) updateDic parameterArray:(NSArray *)parameterArray{
    [[LinkedBeHttpRequest shareInstance] requestUploadUserIcon:self parameterDictionary:updateDic parameterArray:parameterArray requestType:LinkedBe_POST];

}
//上报当前用户liveApp的信息
-(void)accessUploadUserLiveappinfo:(NSMutableDictionary *) updateDic parameterArray:(NSArray *)parameterArray{
    [[LinkedBeHttpRequest shareInstance] requestUserLiveappinfo:self parameterDictionary:updateDic parameterArray:parameterArray requestType:LinkedBe_POST];
}

//消息提醒设置
-(void) accessSystemPush:(NSMutableDictionary*) paramDic{
    [[LinkedBeHttpRequest shareInstance] requestSystemPushWithDelegate:self parameterDictionary:paramDic parameterArray:nil];
}

//用户消息列表
-(void) accessUserSetInfo:(NSMutableDictionary*) paramDic{
    [[LinkedBeHttpRequest shareInstance] requestUserSettingInfoWithDelegate:self parameterDictionary:paramDic parameterArray:nil];
}

#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
    NSArray* myselfOrgArr = nil;
    switch (commandid) {
        case LinkedBe_Myself_PersonalData:
        {
            myselfOrgArr = [MyselfDataProcess getMyselfDataProcessWith:jsonDic];
        }
            break;
        case LinkedBe_Relevantme:
        {
//            myselfOrgArr = [MyselfDataProcess getMyselfRelevantMeDataProcessWith:jsonDic];
        }
            break;
        case LinkedBe_MYSELF_UPDATEUSER:
        {
            
        }
            break;
        case LinkedBe_MYSELF_UPLOAD_IMAGE:
        {
            
        }
            break;
        case LinkedBe_MYSELF_UPLOAD_USERICON:
        {
            
        }
            break;
        case LinkedBe_Member_LoginOut:
        {
        
        }
            break;
        case LinkedBe_System_push:
        {
            
        }
            break;
        case LinkedBe_System_user_set:
        {
            if (jsonDic) {
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UserModel shareUser].user_id,@"userId",
                                     [jsonDic objectForKey:@"msgAlert"],@"chatStatus",
                                     [jsonDic objectForKey:@"dynamicUpdatedAlert"],@"updateStatus",
                                     [jsonDic objectForKey:@"dynamicReplyAlert"],@"replayStatus",
                                     nil];
                [message_push_model updateOrInsertPushStatus:dic];
            }
        }
            break;
        default:
            break;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(getMyselfMessageManagerHttpCallBack:requestCallBackDic:interface:)]) {
        [_delegate getMyselfMessageManagerHttpCallBack:myselfOrgArr requestCallBackDic:jsonDic interface:commandid];
    }
    
}


@end
