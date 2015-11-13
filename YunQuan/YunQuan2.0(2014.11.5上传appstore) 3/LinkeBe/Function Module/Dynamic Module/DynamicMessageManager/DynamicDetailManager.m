//
//  DynamicDetailManager.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicDetailManager.h"

#import "DynamicDetailDataProcess.h"

@implementation DynamicDetailManager

//动态详情
-(void) accessDynamicDetailWith:(NSDictionary*) dic{
    [[LinkedBeHttpRequest shareInstance] requestDynamicDetailDelegate:self parameterDictionary:dic];
}

//评论列表
-(void) accessCommentListWith:(NSDictionary*) dic{
    [[LinkedBeHttpRequest shareInstance] requestCommentListDelegate:self parameterDictionary:dic];
}

//动态详情评论
-(void) accessDynamicDetailComment:(NSMutableDictionary*) dic{
    [[LinkedBeHttpRequest shareInstance] requestPublishCommentDelegate:self parameterDictionary:dic];
}

//删除评论
-(void) accessCommentDeleteWith:(NSDictionary*) dic{
    [[LinkedBeHttpRequest shareInstance] requestDeleteCommentDelegate:self parameterDictionary:dic];
}

//删除动态
-(void) accessDynamicDeleteWith:(NSDictionary*) dic{
    [[LinkedBeHttpRequest shareInstance] requestDeleteDynamicDelegate:self parameterDictionary:dic];
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
        [Common checkProgressHUDShowInAppKeyWindow:@"链接服务器失败" andImage:nil];
    }
    
    switch (commandid) {
        case LinkedBe_Dynamic_detail:
            arr = [DynamicDetailDataProcess getDynamicDetailDataWith:jsonDic];
            break;
        case LinkedBe_Delete_comment:
            arr = [DynamicDetailDataProcess getCommentDeleteBackWith:jsonDic];
            break;
        case LinkedBe_Comment_list:
            arr = [DynamicDetailDataProcess getCommentListWith:jsonDic];
            break;
        case LinkedBe_Comment_dynamic:
            arr = [DynamicDetailDataProcess getDynamicDetailCommentBackWith:jsonDic];
            break;
        case LinkedBe_Delete_dynamic:
            arr = [DynamicDetailDataProcess getDynamicDeleteBackWith:jsonDic];
            break;
        default:
            break;
    }
    [_delegate getDynamicDetailHttpCallBack:arr interface:commandid];
    
    //外面没释放
    [self release];
}

@end
