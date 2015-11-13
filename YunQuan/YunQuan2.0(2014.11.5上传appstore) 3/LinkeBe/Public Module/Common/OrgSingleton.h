//
//  OrgSingleton.h
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrgSingleton : NSObject

+ (OrgSingleton *)shareOrg;

@property (nonatomic, assign) long long orgID;

@property (nonatomic, assign) int orgUserId;

@property (nonatomic, retain) NSString * orgName;

@property (nonatomic, retain) NSString * orgPortrait;

@end
