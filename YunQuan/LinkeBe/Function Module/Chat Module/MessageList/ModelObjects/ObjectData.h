//
//  ObjectData.h
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageData;

@interface ObjectData : NSObject <NSCopying>

@property (nonatomic, assign) long long objectID;

@property (nonatomic, assign) int orgUserID;

@property (nonatomic, retain) NSString *objectName;

@property (nonatomic, retain) NSString *objectPortrait;

- (instancetype)initWithDic:(NSDictionary *)dic;

- (NSMutableDictionary *)getRestoreDic;

- (UIImage *)getDefaultProtraitImg;

/**
 *
 *  根据ID 和类型获取对应ID的聊天对象基本信息 目前有头像和名称
 */
+ (ObjectData *)objectForLatestMessage:(MessageData *)latestMessage;

+ (ObjectData *)speakerForSpekerID:(long long)spekerID;

+ (ObjectData *)objectFromMemberListWithID:(long long)objectID;
//判断是否为小秘书或者组织方
+ (BOOL)isSpecialObjectWithObjectID:(long long)objectID;

@end
