//
//  EmotionStoreData.m
//  ql
//
//  Created by LazySnail on 14-8-22.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import "EmotionStoreData.h"

@implementation EmotionStoreData

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.title = [dic objectForKey:@"title"];
        self.subtitle = [dic objectForKey:@"subtitle"];
        self.emoticonID = [[dic objectForKey:@"packetId"]intValue];
        self.packetName = [dic objectForKey:@"packetName"];
        self.packetPath = [dic objectForKey:@"packetPath"];
        self.iconUrl = [dic objectForKey:@"icon"];
        self.chatIcon = [dic objectForKey:@"chatIcon"];
        self.price = [[dic objectForKey:@"price"]floatValue];
        self.status = [[dic objectForKey:@"status"]intValue];
        self.createTime = [[dic objectForKey:@"createdTime"]longLongValue];
        self.updateTime = [[dic objectForKey:@"updatedTime"]longLongValue];
    }
    return self;
}

@end
