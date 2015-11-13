//
//  Dynamic_page_model.m
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "Dynamic_page_model.h"

@implementation Dynamic_page_model

//插入或更新
+(BOOL) insertOrUpdatePageDataWithDic:(NSDictionary*) dic type:(DynamicPageType)type{
    Dynamic_page_model* model = [[Dynamic_page_model alloc] init];
    model.where = [NSString stringWithFormat:@"type = %d",type];
    
    BOOL status = YES;
    
    NSMutableDictionary* dbDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    [dbDic setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    
    if ([model getList].count) {
        status = [model updateDB:dbDic];
    }else{
        status = [model insertDB:dbDic];
    }
    
    [model release];
    
    return YES;
}

//获取某一类型的页码时间错
+(NSDictionary*) getPageDataWithType:(DynamicPageType) type{
    Dynamic_page_model* model = [[Dynamic_page_model alloc] init];
    model.where = [NSString stringWithFormat:@"type = %d",type];
    
    NSArray* arr = [model getList];
    
    [model release];
    
    NSDictionary* dic = nil;
    
    if (arr.count) {
        dic = [arr firstObject];
    }
    
    return dic;
}

@end
