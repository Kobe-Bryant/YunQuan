//
//  MajorCircleManager.m
//  LinkeBe
//
//  Created by Dream on 14-9-18.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MajorCircleManager.h"
#import "LinkedBeHttpRequest.h"
#import "UserModel.h"
#import "ChatMacro.h"
#import "Cicle_org_model.h"
#import "Circle_member_model.h"
#import "Cicle_member_list_model.h"

@implementation MajorCircleManager

- (void)accessThreeOrganization:(NSMutableDictionary *)dic {
    [[LinkedBeHttpRequest shareInstance] requestThreeOrganizationDelegate:self parameterDictionary:dic parameterArray:nil requestType:LinkedBe_GET];
}

- (void)accessOrganizationMembers:(NSMutableDictionary *)dic {
    [[LinkedBeHttpRequest shareInstance] requestOrganizationMembersDelegate:self parameterDictionary:dic parameterArray:nil requestType:LinkedBe_GET];
}

- (void)accessBusinessCard:(NSMutableDictionary *)dic {
    [[LinkedBeHttpRequest shareInstance] requestBusinessCardDelegate:self parameterDictionary:dic parameterArray:nil requestType:LinkedBe_GET];
}

- (void)accessDetailTempChat:(NSMutableDictionary *)dic {
    [[LinkedBeHttpRequest shareInstance] requestDetailTempChatDelegate:self parameterDictionary:dic parameterArray:nil requestType:LinkedBe_GET];
}
//修改临时会话名称
- (void)accessModifyTempChatName:(NSMutableDictionary *)dic {
    [[LinkedBeHttpRequest shareInstance]requestModifyTempChatNameDelegate:self parameterDictionary:dic parameterArray:nil requestType:LinkedBe_PUT];
}

//商务特权
- (void)accessOrgTools:(NSMutableDictionary *)dic{
    [[LinkedBeHttpRequest shareInstance] requestOrgToolsDelegate:self parameterDictionary:dic parameterArray:nil requestType:LinkedBe_GET];
}

//组织特权
- (void)accessSystemPrivilege:(NSMutableDictionary *)dic{
    [[LinkedBeHttpRequest shareInstance] requestSystemPrivilegeDelegate:self parameterDictionary:dic parameterArray:nil requestType:LinkedBe_GET];
}

//发送邀请 add vincent
- (void)accessUserInvite:(NSMutableDictionary *)dic{
    [[LinkedBeHttpRequest shareInstance] requestUserInviteDelegate:self parameterDictionary:dic parameterArray:nil requestType:LinkedBe_GET];
}

#pragma mark -- 回调
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver {
    NSArray *arr = nil;
    switch (commandid) {
        case LinkeBe_ThreeOrganization: {//三级组织
            LinkedBe_TsType orgTs = ORGANIZATIONTS;
            long long timeTs = [TimeStamp_model getTimeStampWithType:orgTs];
            if (timeTs == 0) {
                arr = [MajorCicleProcess getThreeCircleDataWith:jsonDic];
            } else {
                if (jsonDic) {
                    NSLog(@"jsonDic = %@",jsonDic);
                    Cicle_org_model *model = [[Cicle_org_model alloc]init];

                    long long ts = [[jsonDic objectForKey:@"ts"] longLongValue];
                    LinkedBe_TsType orgts = ORGANIZATIONTS;
                    [TimeStamp_model insertOrUpdateType:orgts time:ts];
                    NSMutableDictionary *oneDic = [jsonDic objectForKey:@"organizations"];
                    if (oneDic) {
                        NSArray *secArray = [oneDic objectForKey:@"subOrgs"];
                        if (secArray.count > 0) {
                            for (NSDictionary *secDic in secArray) {
                                //删除操作
                                if ([[secDic objectForKey:@"disabled"] intValue] == 1) {
                                    model.where = [NSString stringWithFormat:@"id = %d",[[secDic objectForKey:@"id"] intValue]];
                                    NSArray *deleArr = [model getList];
                                    if (deleArr.count > 0) {
                                        [model deleteDBdata];
                                    }
                                } else { //添加组织操作
                                    NSMutableDictionary *tempDic2 = [NSMutableDictionary dictionaryWithDictionary:secDic];
                                    [tempDic2 removeObjectForKey:@"subOrgs"];
                                    model.where = [NSString stringWithFormat:@"id = %d",[[tempDic2 objectForKey:@"id"] intValue]];
                                    NSArray *addArr = [model getList];
                                    if ([addArr count] > 0) {
                                        [model updateDB:tempDic2];
                                    } else {
                                        [model insertDB:tempDic2];
                                    }
                                }
                                NSArray *thrArray = [secDic objectForKey:@"subOrgs"];
                                for (NSDictionary *thrDic in thrArray) {
                                    if ([[thrDic objectForKey:@"disabled"] intValue] == 1) {
                                        model.where = [NSString stringWithFormat:@"id = %d",[[thrDic objectForKey:@"id"] intValue]];
                                        NSArray *deleArr = [model getList];
                                        if (deleArr.count > 0) {
                                            [model deleteDBdata];
                                        }
                                    } else {
                                        NSMutableDictionary *tempDic3 = [NSMutableDictionary dictionaryWithDictionary:thrDic];
                                        model.where = [NSString stringWithFormat:@"id = %d",[[tempDic3 objectForKey:@"id"] intValue]];
                                        NSArray *addArr = [model getList];
                                        if ([addArr count] > 0) {
                                            [model updateDB:tempDic3];
                                        } else {
                                            [model insertDB:tempDic3];
                                        }

                                    }
                                }
                            }
                        }
                    }
                [[NSNotificationCenter defaultCenter]postNotificationName:NewCircleOrgChanged object:nil];
                [model release];
                }
            }
        }
            break;
        case LinkeBe_OrganizationMembers:{ //组织成员
            LinkedBe_TsType memberTs = MEMBERTS;
            long long timeTs = [TimeStamp_model getTimeStampWithType:memberTs];
            if (timeTs == 0) { //第一次登录登录进去请求
                long long ts = [[jsonDic objectForKey:@"ts"] longLongValue];
                LinkedBe_TsType tsType = MEMBERTS;
                [TimeStamp_model insertOrUpdateType:tsType time:ts];
                
                arr = [MajorCicleProcess getCircleMembwesDataWith:jsonDic];
                
            } else { //组织成员变更
                if (jsonDic) {
                    NSArray *memberArray = [jsonDic objectForKey:@"members"];
                    //移动后台人员处理
                    Cicle_member_list_model *listModel = [[Cicle_member_list_model alloc]init];
                    for (NSDictionary *dic in memberArray){
                         listModel.where = [NSString stringWithFormat:@"userId = %d",[[dic objectForKey:@"userId"]intValue]];
                        NSArray *arr = [listModel getList];
                        if (arr.count > 0) {
                            [listModel deleteDBdata];
                        }
                    }
                    [listModel release];
                    [MajorCicleProcess getCircleMembwesDataWith:jsonDic];
                    
                    if ([memberArray count] > 0) {
                        LinkedBe_TsType tsType = MEMBERTS;
                        long long memberTs = [TimeStamp_model getTimeStampWithType:tsType];
                        //这个数组里只有 后台添加的人
                        NSMutableArray *newAddArray = [NSMutableArray array];
                        for (NSDictionary *dic in memberArray) {
                            if ([[dic objectForKey:@"createdTime"] longLongValue] > memberTs){
                                if ([[dic objectForKey:@"state"] intValue] < 3) {
                                    [newAddArray addObject:dic];
                                }
                            }
                        }
                        //目前只有添加才通知小黄条，删除 默默的删了就好了
                        long long ts = [[jsonDic objectForKey:@"ts"] longLongValue];
                        NSMutableDictionary *newAddDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   newAddArray,@"members",
                                                   nil];
                        [newAddDic setValue:[NSNumber numberWithLongLong:ts] forKey:@"memberTs"];
                        [[NSNotificationCenter defaultCenter]postNotificationName:NewCircleMemberChanged object:newAddDic];
                     }
                 }
             }
         }
            break;
        case LinkeBe_BusinessCard: //名片
            arr = [MajorCicleProcess getBusinessCardDataWith:jsonDic];
            break;
        case LinkeBe_DetailTempChat: //临时会话详情
            arr = [MajorCicleProcess getDetailTempChatDataWith:jsonDic];
            break;
        case LinkeBe_ModifyTempChatName: //修改临时会话名称
            arr = [MajorCicleProcess getModidyTempChatNameDataWith:jsonDic];
            break;
        case  LinkedBe_ORG_TOOLS: //商务助手
            arr = [MajorCicleProcess getOrgToolsDataWith:jsonDic];
            break;
        case LinkedBe_SYSTEM_PRIVILEGE: //组织特权
            arr = [MajorCicleProcess getSystemPrivilegeDataWith:jsonDic];
            break;
        case LinkedBe_USER_INVITE: //用户邀请
            arr = [MajorCicleProcess getUserInviteDataWith:jsonDic];
            break;
        default:
            break;
    }
    [_delegate getCircleViewHttpCallBack:arr interface:commandid];
    
    [self release];
}

@end
