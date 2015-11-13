//
//  SnailCommandOrgMemeberChangeNotify.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandOrgMemeberChangeNotify.h"
#import "MajorCircleManager.h"
#import "UserModel.h"
#import "TimeStamp_model.h"

@implementation SnailCommandOrgMemeberChangeNotify

- (void)handleCommandData
{
    //处理圈子成员变更逻辑小黄条展示
    int flg = [[self.bodyDic objectForKey:@"flg"] intValue];
    
    //flg = 1 为成员变更 flg = 2为组织变更
    if (flg == 1) {
        MajorCircleManager *manager = [[MajorCircleManager alloc]init];
        LinkedBe_TsType memberTs = MEMBERTS;
        long long timeTs = [TimeStamp_model getTimeStampWithType:memberTs];
        
        NSMutableDictionary *memberDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [UserModel shareUser].org_id,@"orgId",
                                          [UserModel shareUser].user_id,@"userId",
                                          [NSNumber numberWithLongLong:timeTs],@"ts",
                                          nil];
        [manager accessOrganizationMembers:memberDic];
        RELEASE_SAFE(manager);
    } else if (flg == 2) {
        MajorCircleManager *manager = [[MajorCircleManager alloc]init];
        LinkedBe_TsType orgTs = ORGANIZATIONTS;
        long long timeTs = [TimeStamp_model getTimeStampWithType:orgTs];
        NSMutableDictionary *orgDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [UserModel shareUser].org_id,@"orgId",
                                       [UserModel shareUser].orgUserId,@"orgUserId",
                                       [NSNumber numberWithLongLong:timeTs],@"ts",
                                       nil];
        [manager accessThreeOrganization:orgDic];
        RELEASE_SAFE(manager);
    }
}

@end
