//
//  EmotionStoreData.h
//  ql
//
//  Created by LazySnail on 14-8-22.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    EmotionStoreDataHaveBeenRemove = 2,
    EmotionStoreDataStatusDownloaded = 1,
    EmotionStoreDataStatusNormal = 0,
    EmotionStoreDataStatusDownloading = 3
}EmotionStoreDataStatus;

@interface EmotionStoreData : NSObject

@property(nonatomic, retain) NSString * iconUrl;

@property(nonatomic, retain) NSString * title;

@property(nonatomic, retain) NSString * subtitle;

@property(nonatomic, retain) NSString * packetPath;

@property(nonatomic, retain) NSString * packetName;

@property(nonatomic, assign) float price;

@property(nonatomic, assign) NSInteger emoticonID;

@property(nonatomic, assign) long long createTime;

@property(nonatomic, assign) long long updateTime;

@property(nonatomic, assign) EmotionStoreDataStatus status;

@property(nonatomic, retain) NSString * chatIcon;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
