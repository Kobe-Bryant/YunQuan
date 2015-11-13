//
//  OrgModel.m
//  LinkeBe
//
//  Created by Dream on 14-10-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "OrgModel.h"

@implementation OrgModel

- (void)dealloc
{
    self.name = nil;
    self.membersArray = nil;
    self.childrenArray = nil;
    [super dealloc];
}

@end
