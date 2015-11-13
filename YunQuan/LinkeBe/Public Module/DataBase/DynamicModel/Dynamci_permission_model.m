//
//  Dynamci_permission_model.m
//  LinkeBe
//
//  Created by yunlai on 14-9-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "Dynamci_permission_model.h"

#import "Circle_member_model.h"
#import "SBJson.h"

@implementation Dynamci_permission_model

+(NSArray*) getPermissionMembers{
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
    
    Dynamci_permission_model* dpModel = [[Dynamci_permission_model alloc] init];
    dpModel.where = [NSString stringWithFormat:@"status = 1"];
    dpModel.orderBy = @"orgUserId";
    NSArray* permissionArr = [dpModel getList];
    [dpModel release];
    
    for (NSDictionary* dic in permissionArr) {
        [arr addObject:[[dic objectForKey:@"content"] JSONValue]];
    }
    
    return arr;
}

@end
