//
//  Dynamci_permission_model.h
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"

@interface Dynamci_permission_model : db_model

//获取权限用户信息
+(NSArray*) getPermissionMembers;

@end
