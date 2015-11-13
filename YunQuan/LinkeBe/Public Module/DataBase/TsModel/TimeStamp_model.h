//
//  TimeStamp_model.h
//  LinkeBe
//
//  Created by Dream on 14-10-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"
#import "Global.h"

@interface TimeStamp_model : db_model

+ (void)insertOrUpdateType:(int)typeInt time:(long long)ts;

+ (long long)getTimeStampWithType:(int)typeInt;

@end
