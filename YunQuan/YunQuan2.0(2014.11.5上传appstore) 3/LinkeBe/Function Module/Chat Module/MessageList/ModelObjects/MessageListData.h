//
//  MessageListData.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectData.h"
#import "MessageData.h"

typedef enum {
    searchBarData,
    tableViewData
}DataType;

@interface MessageListData : NSObject

@property (nonatomic, assign) long long ObjectID;

@property (nonatomic, retain) NSString * title;

@property (nonatomic, retain) NSString * portrairt;

@property (nonatomic, assign) int unreadCount;

@property (nonatomic, retain) MessageData * latestMessage;

@property (nonatomic, assign) DataType dataType; //判断是搜索还是tableview的数据 devin

+ (MessageListData *)generateOriginListDataWithObjectID:(long long)objectID andSessionType:(SessionType)type;

- (instancetype)initWithDic:(NSDictionary *)dic;

- (NSMutableDictionary *)getResoreDic;

- (MessageData *)generateSendOriginData;

@end
