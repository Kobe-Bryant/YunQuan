//
//  EmoticonItemData.h
//  ql
//
//  Created by LazySnail on 14-8-28.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomEmotionData;

@interface EmoticonItemData : NSObject

@property(nonatomic, assign) NSInteger itemID;

@property(nonatomic, retain) NSString * title;

@property(nonatomic, retain) NSString * code;

@property(nonatomic, assign) NSInteger emotionID;

@property(nonatomic, retain) NSString * previewIcon;

@property(nonatomic, retain) NSString * emoticonPath;

@property(nonatomic, assign) long long createTime;

@property(nonatomic, assign) long long updateTime;

- (instancetype)initWithDic:(NSDictionary *)dic;

- (CustomEmotionData *)generateCustomEmotionData;

@end
