//
//  EmoticonItemData.m
//  ql
//
//  Created by LazySnail on 14-8-28.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "EmoticonItemData.h"
#import "CustomEmotionData.h"
#import "emoticon_list_model.h"

@implementation EmoticonItemData

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.itemID = [[dic objectForKey:@"id"]intValue];
        self.title = [dic objectForKey:@"title"];
        self.code = [dic objectForKey:@"code"];
        self.emotionID = [[dic objectForKey:@"packetId"]intValue];
        self.previewIcon = [dic objectForKey:@"previewIcon"];
        self.emoticonPath = [dic objectForKey:@"emoticonPath"];
        self.createTime = [[dic objectForKey:@"createdTime"]longLongValue];
        self.updateTime = [[dic objectForKey:@"updatedTime"]longLongValue];
    }
    return self;
}

- (CustomEmotionData *)generateCustomEmotionData
{
    CustomEmotionData * customEmotion = [[CustomEmotionData alloc]init];
    customEmotion.title = self.title;
    customEmotion.emoticonItemID = self.itemID;
    customEmotion.emotionUrl = [[self.emoticonPath copy]autorelease];
    customEmotion.thumbUrl = [[self.previewIcon copy]autorelease];
    NSDictionary * emoticonDic = [emoticon_list_model getEmoticonDicWithEmoticonID:self.emotionID];
    customEmotion.filePath = [emoticonDic objectForKey:@"packetName"];
    return [customEmotion autorelease];
}

@end
