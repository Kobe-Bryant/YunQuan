//
//  MajorCicleProcess.m
//  LinkeBe
//
//  Created by Dream on 14-9-18.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MajorCicleProcess.h"
#import "Cicle_org_model.h"
#import "Circle_member_model.h"
#import "Userinfo_model.h"
#import "OpenCompanyUsers_model.h"
#import "SBJson.h"
#import "UserModel.h"
#import "TimeStamp_model.h"
#import "Global.h"
#import "LinkedBeHttpRequest.h"
#import "Cicle_member_list_model.h"

#import "Dynamic_card_model.h"

@implementation MajorCicleProcess
//三级组织
+(NSArray*) getThreeCircleDataWith:(NSDictionary*) dic {
    NSMutableArray *threeArray = [NSMutableArray arrayWithArray:0];
    
    if (dic) {
        [threeArray addObject:dic];
        
        Cicle_org_model *model = [[Cicle_org_model alloc]init];
        long long ts = [[dic objectForKey:@"ts"] longLongValue];
        LinkedBe_TsType orgts = ORGANIZATIONTS;
        [TimeStamp_model insertOrUpdateType:orgts time:ts];
        
        NSMutableDictionary *oneDic = [dic objectForKey:@"organizations"];
        if (oneDic) {
            NSMutableDictionary *tempDic1 = [NSMutableDictionary dictionaryWithDictionary:oneDic];
            [tempDic1 setValue:[NSNumber numberWithInt:0] forKey:@"parentId"];
            [tempDic1 removeObjectForKey:@"subOrgs"];
            
            model.where = [NSString stringWithFormat:@"id = %d",[[tempDic1 objectForKey:@"id"] intValue]];
            NSArray *oneArray = [model getList];
            if ([oneArray count] > 0) {
                [model updateDB:tempDic1];
            } else {
                [model insertDB:tempDic1];
            }
            
            //判断是否有二级组织
            NSMutableArray *subOrgTwoArray = [oneDic objectForKey:@"subOrgs"];
            
            if ([subOrgTwoArray count] > 0) {
                for (NSDictionary *subOrgTwoDic in subOrgTwoArray) {
                    
                    NSMutableDictionary *tempDic2 = [NSMutableDictionary dictionaryWithDictionary:subOrgTwoDic];
                    [tempDic2 removeObjectForKey:@"subOrgs"];

                    model.where = [NSString stringWithFormat:@"id = %d",[[tempDic2 objectForKey:@"id"] intValue]];
                    NSArray *twoArray = [model getList];
                    if ([twoArray count] > 0) {
                        [model updateDB:tempDic2];
                    } else {
                        [model insertDB:tempDic2];
                    }
                    
                    //判断是否有三级组织
                    NSMutableArray *subOrgThreeArray = [subOrgTwoDic objectForKey:@"subOrgs"];
                    
                    if ([subOrgThreeArray count] > 0) {
                        for (NSDictionary *subOrgThreeDic in subOrgThreeArray){
                            NSMutableDictionary *tempDic3 = [NSMutableDictionary dictionaryWithDictionary:subOrgThreeDic];

                            model.where = [NSString stringWithFormat:@"id = %d",[[tempDic3 objectForKey:@"id"] intValue]];
                            NSArray *threeArray = [model getList];
                            if ([threeArray count] > 0) {
                                [model updateDB:tempDic3];
                            } else {
                                [model insertDB:tempDic3];
                            }
                        }
                    }
                }
            }
        }
        model.where = [NSString stringWithFormat:@"disabled = 1"];
        NSArray *deleArr = [model getList];
        if (deleArr.count > 0) {
            [model deleteDBdata];
        }
        [model release];
        
    }
    return threeArray;
}

//组织成员
+(NSArray*) getCircleMembwesDataWith:(NSDictionary*) dic {
    NSMutableArray *listArray = [NSMutableArray arrayWithArray:0];
    
    if (dic) {
        [listArray addObject:dic];
        Circle_member_model *model = [[Circle_member_model alloc]init];
        Cicle_member_list_model *listModel = [[Cicle_member_list_model alloc]init];
        //成员信息
        NSArray *memberArray = [dic objectForKey:@"members"];
        
        for (NSDictionary *memberDic in memberArray) {
            NSDictionary *listDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [memberDic objectForKey:@"orgId"] ,@"orgId",
                                                  [memberDic objectForKey:@"userId"],@"userId",
                                                   nil];
            listModel.where = [NSString stringWithFormat:@"orgId = %d and userId = %d",[[memberDic objectForKey:@"orgId"] intValue],[[memberDic objectForKey:@"userId"] intValue]];
            NSArray *listArray = [listModel getList];
            if (listArray.count > 0) {
                [listModel updateDB:listDic];
            } else {
                [listModel insertDB:listDic];
            }
            
            NSDictionary *tempDic = [NSDictionary dictionaryWithDictionary:memberDic];
            model.where = [NSString stringWithFormat:@"userId = %d",[[memberDic objectForKey:@"userId"] intValue]];
            NSArray *array = [model getList];
            if ([array count] > 0) {
                [model updateDB:tempDic];
            } else {
                [model insertDB:tempDic];
            }
        }
         //删除state大于2的人
        model.where = [NSString stringWithFormat:@"state = 4"];
        NSArray *deleArr = [model getList];
        if (deleArr.count > 0) {
            for (NSDictionary* memDic in deleArr) {
                [Dynamic_card_model deleteAllDynamicWithUserId:[[memDic objectForKey:@"userId"] intValue]];
            }
            [model deleteDBdata];
        }
        RELEASE_SAFE(model);
        RELEASE_SAFE(listModel);
    }
    return listArray;
}

//名片
+ (NSArray *)getBusinessCardDataWith:(NSDictionary *)dic {
    NSMutableArray *businessArray = [NSMutableArray array];
    if (dic) {
        [businessArray addObject:dic];
        
        //booky更换用户头像
        [Circle_member_model updatePortraitWithDic:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [dic objectForKey:@"userId"],@"userId",
                                                    [dic objectForKey:@"portrait"],@"portrait",nil]];
        
    }
    return businessArray;
}

//临时会话详情
+ (NSArray *)getDetailTempChatDataWith:(NSDictionary *)dic {
    NSMutableArray *tempChatArray = [NSMutableArray array];

    if (dic) {
        [tempChatArray addObject:dic];
    }
    return tempChatArray;
}

+ (NSArray *)getModidyTempChatNameDataWith:(NSDictionary *)dic {
    NSMutableArray *modifyTempChatArray = [NSMutableArray array];
    if (dic) {
        [modifyTempChatArray addObject:dic];
    }
    return modifyTempChatArray;
}

//商务助手
+ (NSArray *)getOrgToolsDataWith:(NSDictionary *)dic{
    NSMutableArray *orgToolsArray = [NSMutableArray array];
    if (dic) {
        NSArray *arr = [dic objectForKey:@"plugs"];
        for (NSDictionary* dic in arr) {
            NSDictionary* plugDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [dic objectForKey:@"id"],@"id",
                                     [dic JSONRepresentation],@"content",
                                     nil];
            
            [orgToolsArray addObject:plugDic];
        }
    }
    return orgToolsArray;
}

//商务特权
+ (NSArray *)getSystemPrivilegeDataWith:(NSDictionary *)dic {
    NSMutableArray* array = [NSMutableArray array];
    if (dic) {
        [UserModel shareUser].privilegeBigImage = [dic objectForKey:@"imageOrgLogoPath"];
        
        NSArray* privilegeArr = [dic objectForKey:@"privileges"];
        for (NSDictionary* dic in privilegeArr) {
            NSDictionary* pdic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [dic objectForKey:@"id"],@"id",
                                   [dic JSONRepresentation],@"content",                                  nil];
            [array addObject:pdic];
        }
    }
    return array;
}

//注册邀请
+ (NSArray *)getUserInviteDataWith:(NSDictionary *)dic{
    NSMutableArray *userInviteArray = [NSMutableArray array];
    if (dic) {
        [userInviteArray addObject:dic];
    }
    return userInviteArray;
}
@end
