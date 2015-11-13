//
//  DynamicEditDataProcess.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicEditDataProcess.h"

@implementation DynamicEditDataProcess

+(NSArray*) getDynamicEditPublishBackWith:(NSDictionary *)dic{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    if (dic) {
        [arr addObject:dic];
    }
    
    return arr;
}

@end
