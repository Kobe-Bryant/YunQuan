//
//  LoginMessageDataProcess.m
//  LinkeBe
//
//  Created by yunlai on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "LoginMessageDataProcess.h"
#import "SBJson.h"
#import "chooseOrg_model.h"
#import "db_model.h"
#import "Global.h"

@implementation LoginMessageDataProcess
+(NSArray*)getOrgListDataWith:(NSDictionary*) orgListDic{
    NSMutableArray* orgMutableArray = [NSMutableArray arrayWithCapacity:0];
    if (orgListDic) {
        NSString * userName = [orgListDic objectForKey:@"userId"];
        // 设置默认用户名
        [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kPreviousUserName];
        
        chooseOrg_model *orgMod = [[chooseOrg_model alloc] init];
        [orgMod deleteDBdata];
        orgMod.where = nil;
        NSMutableArray * allOrgIds = [NSMutableArray arrayWithCapacity:5];
        NSArray *orgArr = [orgListDic objectForKey:@"organzations"];
        for (int i =0; i<orgArr.count; i++) {
            NSDictionary *orgDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[orgArr objectAtIndex:i] objectForKey:@"id"],@"id",
                                [[orgArr objectAtIndex:i] objectForKey:@"orgUserId"],@"orgUserId",
                                [[orgArr objectAtIndex:i] objectForKey:@"isDisabled"],@"isDisabled",
                                [[[orgArr objectAtIndex:i] objectForKey:@"welcome"] objectForKey:@"id"],@"welcome_id",
                                [[[orgArr objectAtIndex:i] objectForKey:@"welcome"] objectForKey:@"userId"],@"welcome_userId",
                                 [[[orgArr objectAtIndex:i] objectForKey:@"welcome"] objectForKey:@"orgId"],@"welcome_orgId",
                                [[orgArr objectAtIndex:i] objectForKey:@"orgName"],@"orgName",
                                [[orgArr objectAtIndex:i] objectForKey:@"catPic"],@"catPic",
                                  [[[orgArr objectAtIndex:i] objectForKey:@"welcome"] objectForKey:@"content"],@"welcome_content",[[[orgArr objectAtIndex:i] objectForKey:@"welcome"] objectForKey:@"luokuan"],@"welcome_luokuan",[[[orgArr objectAtIndex:i] objectForKey:@"welcome"] objectForKey:@"btn"],@"welcome_btn",
                                [[[orgArr objectAtIndex:i] objectForKey:@"welcome"] objectForKey:@"pic"],@"welcome_pic",
                                nil];
            
            [allOrgIds addObject:[[orgArr objectAtIndex:i] objectForKey:@"id"]];
            orgMod.where = [NSString stringWithFormat:@"id = %d",[[[orgArr objectAtIndex:i] objectForKey:@"id"] intValue]];
            
            NSMutableArray *dbArray = [orgMod getList];
            if ([dbArray count] > 0)
            {
                [orgMod updateDB:orgDic];
            }
            else{
                [orgMod insertDB:orgDic];
            }
        }
        NSString * userAccountName = [[NSUserDefaults standardUserDefaults]objectForKey:kPreviousUserName];
        NSString * userOrgJsonStr = [allOrgIds JSONRepresentation];
        
        //更新应用系统数据库 用户快速切换用户
        NSDictionary * insertWholeUserOrgDic = [NSDictionary dictionaryWithObjectsAndKeys:userAccountName,@"user_account_name",
                                                userOrgJsonStr,@"all_org_numbers",
                                                nil];
        [whole_users_model insertOrUpdataUserInfoWithDic:insertWholeUserOrgDic];
        
        orgMutableArray = [orgMod getList];
    }
    return orgMutableArray;
}
@end
