//
//  SessionDataFactory.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OriginData.h"
#import "CustomEmotionData.h"
#import "PictureData.h"
#import "TextData.h"
#import "VoiceData.h"
#import "TogetherData.h"
#import "SystemNofityData.h"
#import "IWantData.h"
#import "IHaveData.h"

@interface SessionDataFactory : NSObject

+ (OriginData *)generateInstantDataWithDic:(NSDictionary *)dic;

+ (OriginData *)dataWithDataType:(DataMessageType)type;

@end
