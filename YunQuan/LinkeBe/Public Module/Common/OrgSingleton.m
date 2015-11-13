//
//  OrgSingleton.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "OrgSingleton.h"

@implementation OrgSingleton

+ (OrgSingleton *)shareOrg
{
    static OrgSingleton *org = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        org = [[self alloc]init];
    });
    return org;
}

@end
