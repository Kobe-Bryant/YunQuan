
//
//  MyselfDataProcess.m
//  LinkeBe
//
//  Created by yunlai on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MyselfDataProcess.h"
#import "Userinfo_model.h"
#import "OpenCompanyUsers_model.h"
#import "SBJson.h"
#import "RelevantMe_model.h"
#import "Companie_LiveApp_model.h"
#import "TimeStamp_model.h"

@implementation MyselfDataProcess
//我的个人的资料
+(NSArray*) getMyselfDataProcessWith:(NSDictionary*) orgListDic{
    NSMutableArray* myselfArray = [NSMutableArray arrayWithCapacity:0];
    [myselfArray addObject:orgListDic];
    
    long long ts = [[orgListDic objectForKey:@"ts"] longLongValue];
    LinkedBe_TsType myselfTs = MYSELFINFORPROCESS;
    [TimeStamp_model insertOrUpdateType:myselfTs time:ts];
    
    Userinfo_model *userInfoModel = [[Userinfo_model alloc]init];
    // 个人信息
    NSDictionary *userInfoDic = [orgListDic objectForKey:@"userinfo"];
    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [userInfoDic objectForKey:@"orgUserId"],@"orgUserId",
                             [userInfoDic JSONRepresentation],@"content",
                             nil];
    userInfoModel.where = [NSString stringWithFormat:@"orgUserId = %d",[[userInfoDic objectForKey:@"orgUserId"] intValue]];
    NSArray *userArray = [userInfoModel getList];
    if ([userArray count] > 0) {
        [userInfoModel updateDB:userDic];
    } else {
        [userInfoModel insertDB:userDic];
    }
    
    OpenCompanyUsers_model *openCompanyModel = [[OpenCompanyUsers_model alloc]init];
    //开通的企业
    NSArray *openCompanyArray = [orgListDic objectForKey:@"openCompanyUsers"];
    for (NSDictionary *openDic in openCompanyArray) {
        NSDictionary *openCompanyDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [openDic objectForKey:@"id"],@"id",
                                        [openDic JSONRepresentation],@"content",
                                        nil];
        openCompanyModel.where = [NSString stringWithFormat:@"id = %d",[[openDic objectForKey:@"id"] intValue]];
        NSArray *openArray = [openCompanyModel getList];
        if ([openArray count] > 0) {
            [openCompanyModel updateDB:openCompanyDic];
        } else {
            [openCompanyModel insertDB:openCompanyDic];
        }
    }
    
   //    与我相关
    RelevantMe_model *relevantMeModel = [[RelevantMe_model alloc] init];
    NSDictionary *relevantMeDic = [orgListDic objectForKey:@"relevantMe"];
    NSDictionary *relevantDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [relevantMeDic objectForKey:@"id"],@"id",
                                    [relevantMeDic JSONRepresentation],@"content",
                                    nil];
    relevantMeModel.where = [NSString stringWithFormat:@"id = %d",[[relevantMeDic objectForKey:@"id"] intValue]];
    NSArray *relevantArray = [relevantMeModel getList];
    if ([relevantArray count] > 0) {
        [relevantMeModel updateDB:relevantDic];
    } else {
        [relevantMeModel insertDB:relevantDic];
    }
    
//    公司开通的liveapp
    Companie_LiveApp_model *companyLiveModel = [[Companie_LiveApp_model alloc] init];
    NSDictionary *companyLiveModelDic = [orgListDic objectForKey:@"companies"];
    for (NSDictionary *companyLiveDic in companyLiveModelDic) {
        NSDictionary *liveAppDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [companyLiveDic JSONRepresentation],@"content",
                                    nil];
        //    companyLiveModel.where = [NSString stringWithFormat:@"id = %d",[[relevantMeDic objectForKey:@"id"] intValue]];
        NSArray *liveAppArray = [companyLiveModel getList];
        if ([liveAppArray count] > 0) {
            [companyLiveModel updateDB:liveAppDic];
        } else {
            [companyLiveModel insertDB:liveAppDic];
        }
    }
    [companyLiveModel release];
    [userInfoModel release];
    [openCompanyModel release];
    [relevantMeModel release];
    
    return myselfArray;
}

//与我相关
+(NSArray*) getMyselfRelevantMeDataProcessWith:(NSDictionary*) relevantMeDic{
    NSMutableArray* myselfRelevantMeArray = [NSMutableArray arrayWithCapacity:0];
    [myselfRelevantMeArray addObject:relevantMeDic];
    
    return myselfRelevantMeArray;
}


@end
