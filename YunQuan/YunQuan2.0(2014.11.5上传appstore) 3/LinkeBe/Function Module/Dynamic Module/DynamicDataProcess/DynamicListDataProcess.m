//
//  DynamicListDataProcess.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicListDataProcess.h"

#import "Dynamic_card_model.h"
#import "SBJson.h"
#import "Dynamic_page_model.h"
#import "Dynamci_permission_model.h"

@implementation DynamicListDataProcess

+(NSArray*) getDynamicListDataWith:(NSDictionary *)dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        long long ts = [[dic objectForKey:@"ts"] longLongValue];
        
        NSDictionary* publishPages = [dic objectForKey:@"publishPages"];
        
        int pageNum = [[publishPages objectForKey:@"pageNumber"] intValue];
        int pageSize = [[publishPages objectForKey:@"pageSize"] intValue];
        int totalCount = [[publishPages objectForKey:@"totalCount"] intValue];
        int pages = [[publishPages objectForKey:@"pages"] intValue];
        //插入数据库存储
        NSMutableDictionary* pageDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithLongLong:ts],@"ts",
                                 [NSNumber numberWithInt:pageNum],@"pageNumber",
                                 [NSNumber numberWithInt:pageSize],@"pageSize",
                                 [NSNumber numberWithInt:totalCount],@"totalCount",
                                 [NSNumber numberWithInt:pages],@"pages",
                                 nil];
        if (ts == 0) {
            [pageDic removeObjectForKey:@"ts"];
        }
        [Dynamic_page_model insertOrUpdatePageDataWithDic:pageDic type:DynamicPageTypeList];
        
        NSArray* publishArr = [publishPages objectForKey:@"result"];
        
        for (NSDictionary* tpdic in publishArr) {
            int publishId = [[tpdic objectForKey:@"id"] intValue];
            int type = [[tpdic objectForKey:@"type"] intValue];
            long long created = [[tpdic objectForKey:@"createdTime"] longLongValue];
            
            //更换用户头像
            [Circle_member_model updatePortraitWithDic:[NSDictionary dictionaryWithObjectsAndKeys:
                                                        [tpdic objectForKey:@"userId"],@"userId",
                                                        [tpdic objectForKey:@"portrait"],@"portrait",nil]];
            
            int deleteState = [[tpdic objectForKey:@"delete"] intValue];
            //如果delete为1，则不插入数据库
            if (deleteState == 1) {
                continue;
            }
            
            NSDictionary* pDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:publishId],@"id",
                                  [NSNumber numberWithInt:type],@"type",
                                  [NSNumber numberWithLongLong:created],@"createdTime",
                                  [tpdic JSONRepresentation],@"content",
                                  [tpdic objectForKey:@"userId"],@"userId",
                                  nil];
            //插入数据库
            [Dynamic_card_model insertOrUpdateDynamicCardWithContentDic:pDic];
        }
        
        //检查数据库缓存，删除超过100条得老数目
        [Dynamic_card_model cacheDynamicCardData];
        
//        [arr addObjectsFromArray:publishArr];
        
        //移除掉delete为1的数据
        for (NSDictionary* tmpdic in publishArr) {
            if ([[tmpdic objectForKey:@"delete"] intValue] == 0) {
//                [arr removeObject:tmpdic];
                [arr addObject:tmpdic];
            }
        }
    }
    
    return arr;
}

+(NSArray*) getDynamicListFastCommonBackWith:(NSDictionary *)dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        [arr addObject:dic];
    }
    
    return arr;
}

+(NSArray*) getPermissionListWith:(NSDictionary*) dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        BOOL havePermission = [[dic objectForKey:@"DohaveRole"] boolValue];
        
        [UserModel shareUser].isHavePermission = havePermission;
        
        Dynamci_permission_model* model = [[Dynamci_permission_model alloc] init];
        [model deleteDBdata];
        
        NSArray* roleArr = [dic objectForKey:@"orgRoleList"];
        
        for (NSDictionary* dic in roleArr) {
            
            int orgUserId = [[dic objectForKey:@"orgUserId"] intValue];
            
            NSDictionary* pdic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt:orgUserId],@"orgUserId",
                                  [dic JSONRepresentation],@"content",
                                  [dic objectForKey:@"status"],@"status",
                                  nil];
            [model insertDB:pdic];
        }
        
        [model release];
        [arr addObject:dic];
    }
    
    return arr;
}

//获取我的动态列表
+(NSArray*) getMyDynamicWith:(NSDictionary*) dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        [arr addObject:dic];
    }
    
    return arr;
}

@end
