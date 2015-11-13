//
//  SessionDataFactory.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SessionDataFactory.h"

@implementation SessionDataFactory

+ (OriginData *)dataWithDataType:(DataMessageType)type
{
    OriginData * data = nil;
    switch (type) {
        case DataMessageTypeText:
        {
            data = [[TextData alloc]init];
        }
            break;
        case DataMessageTypePicture:
        {
            data = [[PictureData alloc]init];
        }
            break;
        case DataMessageTypeVoice:
        {
            data = [[VoiceData alloc]init];
        }
            break;
        case DataMessageTypeCustomEmotion:
        {
            data = [[CustomEmotionData alloc]init];
        }
            break;
        case DataMessageTypeTogether:
        {
            data = [[TogetherData alloc]init];
        }
            break;
        case DataMessageTypeIWant:
        {
            data = [[IWantData alloc]init];
        }
            break;
        case DataMessageTypeIHave:
        {
            data = [[IHaveData alloc]init];
        }
            break;
        default:
            break;
    }
    return [data autorelease];
}

+ (OriginData *)generateInstantDataWithDic:(NSDictionary *)dic
{
    DataMessageType dataType = [[dic objectForKey:@"objtyp"]intValue];
    
    OriginData *resultData = nil;
    switch (dataType) {
        case DataMessageTypeText:
             resultData = [[TextData alloc]initWithDic:dic];
            break;
        case DataMessageTypePicture:
            resultData = [[PictureData alloc]initWithDic:dic];
            break;
        case DataMessageTypeVoice:
            resultData = [[VoiceData alloc]initWithDic:dic];
            break;
        case DataMessageTypeIWant:
            resultData = [[IWantData alloc]initWithDic:dic];
            break;
        case DataMessageTypeIHave:
            resultData = [[IHaveData alloc]initWithDic:dic];
            break;
        case DataMessageTypeCustomEmotion:
            resultData = [[CustomEmotionData alloc]initWithDic:dic];
            break;
        case DataMessageTypeTogether:
            resultData = [[TogetherData alloc]initWithDic:dic];
            break;
        case DataMessageTypeSystemNofity:
            resultData = [[SystemNofityData alloc]initWithDic:dic];
            break;
        default:
            break;
    }
    return [resultData autorelease];
}


@end
