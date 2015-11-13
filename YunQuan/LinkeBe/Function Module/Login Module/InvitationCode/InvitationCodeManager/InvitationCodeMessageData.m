

//
//  InvitationCodeMessageData.m
//  LinkeBe
//
//  Created by yunlai on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "InvitationCodeMessageData.h"
#import "LinkedBeHttpRequest.h"

@implementation InvitationCodeMessageData

//验证邀请码的接口
-(void) accessInvitationCodeMessageData:(NSMutableDictionary*) requestDic{
    [[LinkedBeHttpRequest shareInstance] requestUserInvitationcodeDelegate:self parameterDictionary:requestDic parameterArray:nil parameterString:nil];
}


#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
//    NSArray* loginOrgArr = nil;
//    switch (commandid) {
//        case LinkedBe_User_Invitationcode:
//        {
//         
//        }
//            break;
//        default:
//            break;
//    }
    [_delegate getInvitationCodeMessageDataHttpCallBack:nil requestCallBackDic:jsonDic interface:commandid];
}

@end
