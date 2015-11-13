//
//  TempChat_list_model.h
//  LinkeBe
//
//  Created by Dream on 14-10-8.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"

@interface TempChat_list_model : db_model

+ (BOOL)insertOrUpdateTempChatListWithDic:(NSDictionary *)dic;

+ (NSDictionary *)getTempChatContentDataWith:(long long)circleId;

+ (BOOL)deleteDataWithTempCircleID:(long long)circleID;

@end
