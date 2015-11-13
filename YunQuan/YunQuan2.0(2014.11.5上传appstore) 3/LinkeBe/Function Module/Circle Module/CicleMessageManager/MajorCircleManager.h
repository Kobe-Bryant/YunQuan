//
//  MajorCircleManager.h
//  LinkeBe
//
//  Created by Dream on 14-9-18.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "interface_LinkedBe.h"
#import "MajorCicleProcess.h"
#import "TimeStamp_model.h"

@protocol MajorCircleManagerDelegate <NSObject>

- (void)getCircleViewHttpCallBack:(NSArray *)arr interface:(LinkedBe_WInterface)interface;

@end

@interface MajorCircleManager : NSObject

@property (nonatomic,assign) id<MajorCircleManagerDelegate> delegate;

//三级组织
- (void)accessThreeOrganization:(NSMutableDictionary *)dic;

//组织成员
- (void)accessOrganizationMembers:(NSMutableDictionary *)dic;

//名片
- (void)accessBusinessCard:(NSMutableDictionary *)dic;

//临时会话详情
- (void)accessDetailTempChat:(NSMutableDictionary *)dic;

//修改临时会话名称
- (void)accessModifyTempChatName:(NSMutableDictionary *)dic;

//商务特权
- (void)accessOrgTools:(NSMutableDictionary *)dic;

//组织特权
- (void)accessSystemPrivilege:(NSMutableDictionary *)dic;

//发送邀请 /user/ invite add vincent
- (void)accessUserInvite:(NSMutableDictionary *)dic;

@end
