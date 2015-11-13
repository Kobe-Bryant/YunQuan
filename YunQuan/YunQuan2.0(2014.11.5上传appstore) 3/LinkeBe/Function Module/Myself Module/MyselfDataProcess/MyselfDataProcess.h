//
//  MyselfDataProcess.h
//  LinkeBe
//
//  Created by yunlai on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyselfDataProcess : NSObject
//我的个人的资料
+(NSArray*) getMyselfDataProcessWith:(NSDictionary*) orgListDic;
//与我相关的资料
+(NSArray*) getMyselfRelevantMeDataProcessWith:(NSDictionary*) relevantMeDic;

@end
