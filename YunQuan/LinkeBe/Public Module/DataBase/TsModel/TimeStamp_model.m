//
//  TimeStamp_model.m
//  LinkeBe
//
//  Created by Dream on 14-10-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "TimeStamp_model.h"

@implementation TimeStamp_model
+ (void)insertOrUpdateType:(int)typeInt time:(long long)ts{

    TimeStamp_model *model = [[TimeStamp_model alloc]init];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:typeInt],@"type",
                                      [NSNumber numberWithLongLong:ts],@"timestamp",
                                       nil];
    
    model.where = [NSString stringWithFormat:@"type = %d",typeInt];
    NSArray *arr = [model getList];
    if ([arr count] == 0) {
        [model insertDB:dic];
    } else {
        [model updateDB:dic];
    }
    RELEASE_SAFE(model);
}

+ (long long)getTimeStampWithType:(int)typeInt {
    long long TimeStamp = 0;
    TimeStamp_model *model = [[TimeStamp_model alloc]init];
    model.where = [NSString stringWithFormat:@"type = %d",typeInt];
    NSArray *arr = [model getList];
    
    if ([arr count] == 1) {
        NSDictionary *dic = [arr firstObject];
        TimeStamp = [[dic objectForKey:@"timestamp"] longLongValue];
    } else {
        NSLog(@"表里面没有这个字段 或者 表里面有重复字段");
    }
    
    return TimeStamp;
}

@end
