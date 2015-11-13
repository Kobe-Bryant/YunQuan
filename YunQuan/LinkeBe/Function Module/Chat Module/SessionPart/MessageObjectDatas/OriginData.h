//
//  OriginData.h
//  ql
//
//  Created by LazySnail on 14-5-9.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMacro.h"

// 实际上是 objtype 用于判断消息类型

typedef enum
{
    DataMessageTypeText = 1,
    DataMessageTypePicture = 2,
    DataMessageTypePictureAndText = 3,
    DataMessageTypeVoice = 4,
    DataMessageTypeIWant = 6,
    DataMessageTypeIHave = 5,
    DataMessageTypeTogether = 7,
    DataMessageTypeCustomEmotion = 8,
    DataMessageTypeSystemNofity = 9
}DataMessageType;

typedef enum{
    OriginDataStatusUnread = 0,
    OriginDataStatusReaded = 1
}OriginDataStatus;

@interface OriginData : NSObject <NSCopying>

//对象类型 2为图片 6 为语音 7 为我有我要
@property (nonatomic, readonly) DataMessageType objtype;
//发送状态 0为未读取 1为读取
@property (nonatomic, assign) OriginDataStatus dataStatus;
//消息体dataDic 用于子类赋值
@property (nonatomic, retain) NSDictionary * dataDic;



- (NSDictionary *)getDic;

- (NSDictionary *)genterateComplateDic;

- (instancetype)initWithDic:(NSDictionary *)dic;

- (NSString *)dataListDescreption;

@end
