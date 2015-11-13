//
//  Dynamic_page_model.h
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"

typedef enum{
    DynamicPageTypeList = 1,
}DynamicPageType;

@interface Dynamic_page_model : db_model

//插入或更新
+(BOOL) insertOrUpdatePageDataWithDic:(NSDictionary*) dic type:(DynamicPageType) type;

//获取某一类型的页码时间错
+(NSDictionary*) getPageDataWithType:(DynamicPageType) type;

@end
