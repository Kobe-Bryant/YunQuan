//
//  SystemNofityData.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SystemNofityData.h"

@implementation SystemNofityData

@synthesize objtype = _objtype;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _objtype = DataMessageTypeSystemNofity;
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super initWithDic:dic];
    if (self) {
        _objtype = DataMessageTypeSystemNofity;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
