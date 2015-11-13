//
//  SnailiMDataManager.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageData;

@interface SnailiMDataManager : NSObject

//生成一个消息发送器的单例
+ (SnailiMDataManager *)shareiMDataManager;

//向服务端发送消息对象
- (void)sendMessageData:(MessageData *)data;

//触发震动通知
- (void)playVibrate;

@end
