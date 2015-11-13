//
//  ContactModel.m
//  LinkeBe
//
//  Created by Dream on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel

- (void)dealloc
{
    self.iconStr = nil;
    self.nameStr = nil;
    self.positionStr = nil;
    self.companyStr = nil;
    self.sexString = nil;
    [super dealloc];
}

@end
