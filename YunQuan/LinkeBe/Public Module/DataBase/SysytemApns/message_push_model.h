//
//  message_push_model.h
//  LinkeBe
//
//  Created by yunlai on 14-10-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"

@interface message_push_model : db_model

//更新状态
+(void) updateOrInsertPushStatus:(NSDictionary*) dic;

//获取用户的推送设置信息
+(NSDictionary*) getMessagePushInfoWithUserId:(int) userId;

@end
