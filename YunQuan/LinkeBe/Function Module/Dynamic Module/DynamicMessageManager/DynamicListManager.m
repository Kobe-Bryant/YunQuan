//
//  DynamicListManager.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicListManager.h"

#import "DynamicListDataProcess.h"

#import "LinkedBeHttpRequest.h"

@implementation DynamicListManager

-(void) accessDynamicList:(NSMutableDictionary *)dic{
    [[LinkedBeHttpRequest shareInstance] requestDynamicListDelegate:self parameterDictionary:dic];
}

-(void) accessDynamicListCommentwithParam:(NSMutableDictionary *)param{
    [[LinkedBeHttpRequest shareInstance] requestPublishCommentDelegate:self parameterDictionary:param];
    
}

//查询发布动态权限
-(void) checkPublishPermissionWithParam:(NSDictionary*) param{
    [[LinkedBeHttpRequest shareInstance] requestPublishPermissionWithDelegate:self parameterDictionary:param];
}

//请求我的动态
-(void) accessMyDynamic:(NSMutableDictionary*) dic{
    [[LinkedBeHttpRequest shareInstance] requestMyDyanmicListWithDelegate:self parameterDictionary:dic];
}

#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
    
    NSArray* arr = nil;
    if (jsonDic) {
        int errcode = [[jsonDic objectForKey:@"errcode"] intValue];
        if (errcode != 0 && errcode != -2) {
            [Common checkProgressHUDShowInAppKeyWindow:[jsonDic objectForKey:@"errmsg"] andImage:nil];
            jsonDic = nil;
        }
    }else{
        if (commandid != LinkedBe_PermissionList) {
            [Common checkProgressHUDShowInAppKeyWindow:@"链接服务器失败" andImage:nil];
        }
    }
    
    switch (commandid) {
        case Linkedbe_DynamicList:
            arr = [DynamicListDataProcess getDynamicListDataWith:jsonDic];
            break;
        case LinkedBe_Comment_dynamic:
            arr = [DynamicListDataProcess getDynamicListFastCommonBackWith:jsonDic];
            break;
        case LinkedBe_PermissionList:
            arr = [DynamicListDataProcess getPermissionListWith:jsonDic];
            break;
        case LinkedBe_My_Dynamic:
            arr = [DynamicListDataProcess getMyDynamicWith:jsonDic];
            break;
        default:
            break;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(getDynamicListHttpCallBack:interface:)]) {
        [_delegate getDynamicListHttpCallBack:arr interface:commandid];
    }
    
    [self release];
}

-(void) dealloc{
    [super dealloc];
}

@end
