//
//  SecretaryOrgInfoTable_model.h
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "db_model.h"

typedef enum
{
    SpecialContectSecretary = 2,
    SpecialContectOrg = 1,
}SpecialContect;

@interface SecretaryOrgInfoTable_model : db_model

+ (BOOL)insertOrUpdateInfoWithDic:(NSDictionary *)dic;

+ (NSDictionary *)getObjectInfoDicWithObject_type:(SpecialContect)type;

@end
