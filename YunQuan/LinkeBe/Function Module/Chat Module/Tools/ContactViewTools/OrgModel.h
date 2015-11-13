//
//  OrgModel.h
//  LinkeBe
//
//  Created by Dream on 14-10-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrgModel : NSObject

@property (nonatomic, assign) long long orgId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *membersArray;
@property (nonatomic, assign) int selectedState; // 0和1是判断二级组织  2和3是判断三级组织
@property (nonatomic, retain) NSMutableArray *childrenArray;

@end
