//
//  application_db_model.m
//  ql
//
//  Created by LazySnail on 14-7-2.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "application_db_model.h"

@implementation application_db_model

- (instancetype)init
{
    self = [super init];
    if (self) {
        dbFilePath=[FileManager getFileDBPath:AppDataBaseName];
        db=[FMDatabase databaseWithPath:dbFilePath];
    }
    return self;
}

@end
