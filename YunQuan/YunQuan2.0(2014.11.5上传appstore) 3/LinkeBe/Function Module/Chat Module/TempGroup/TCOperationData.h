//
//  TCOperationData.h
//  LinkeBe
//
//  Created by LazySnail on 14-1-9.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCOperationData : NSObject

//消息id 客户端生成 用于确定发送消息的发送结果
@property (nonatomic, assign) int dataLocalID;

//临时圈子ID 如果不为0 则为添加成员 默认为0;
@property (nonatomic, assign) long long tempCircleID;

@end
