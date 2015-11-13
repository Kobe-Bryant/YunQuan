//
//  OriginData.m
//  ql
//
//  Created by LazySnail on 14-5-9.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "OriginData.h"
#import "TextData.h"
#import "PictureData.h"
#import "VoiceData.h"
#import "IWantData.h"
#import "IHaveData.h"
#import "CustomEmotionData.h"

@implementation OriginData

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.dataDic = [dic objectForKey:@"data"];
        self.dataStatus = [[dic objectForKey:@"dataStatus"]intValue];
    }
    
    return self;
}

- (NSDictionary *)getDic{
    return [self genterateComplateDic];
}

- (NSDictionary *)genterateComplateDic
{
    NSDictionary * tempDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:self.objtype],@"objtyp",
                              self.dataDic,@"data",[NSNumber numberWithInt:self.dataStatus],@"dataStatus",nil];
    return tempDic;
}

- (id)copyWithZone:(NSZone *)zone
{
    return nil;
}

- (NSString *)dataListDescreption{
    NSAssert(false, @"Must be over ride");
    return nil;
}

@end
