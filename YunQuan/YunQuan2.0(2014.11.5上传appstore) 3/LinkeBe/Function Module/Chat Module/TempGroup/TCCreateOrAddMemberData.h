//
//  TCCreateOrAddMemberData.h
//  LinkeBe
//
//  Created by LazySnail on 14-1-8.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCOperationData.h"

typedef enum{
    TCCADataTypeCreate,
    TCCADataTypeAdd
}TCCADataType;

@interface TCCreateOrAddMemberData : TCOperationData

//添加的用户或者创建的用户数组
@property (nonatomic, retain) NSMutableArray * memberArr;

//操作类型
@property (nonatomic, assign) TCCADataType operateType;

- (NSDictionary *)getiMSendDic;

- (instancetype)initWithIMAckDic:(NSDictionary *)dic;

@end
