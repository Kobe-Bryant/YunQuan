//
//  CompanyInfobrowserModel.m
//  ql
//
//  Created by Dream on 14-8-16.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "CompanyInfobrowserModel.h"

@implementation CompanyInfobrowserModel
@synthesize logo_url = _logo_url;
@synthesize company_name = _company_name;
@synthesize liveapp_url = _liveapp_url;
@synthesize liveapp_list = _liveapp_list;
@synthesize pv =_pv;

- (void)dealloc
{
    [_logo_url release]; _logo_url = nil;
    [_company_name release]; _company_name = nil;
    [_liveapp_url release]; _liveapp_url = nil;
    [_liveapp_list release]; _liveapp_list = nil;
    [super dealloc];
}

@end
