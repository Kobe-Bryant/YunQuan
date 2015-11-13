//
//  LoginMessageDataProcess.h
//  LinkeBe
//
//  Created by yunlai on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginMessageDataProcess : NSObject
//获取组织列表的数据
+(NSArray*) getOrgListDataWith:(NSDictionary*) orgListDic;
@end
