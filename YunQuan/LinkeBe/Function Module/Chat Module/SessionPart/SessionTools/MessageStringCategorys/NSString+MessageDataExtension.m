//
//  NSString+MessageDataExtension.m
//  ql
//
//  Created by LazySnail on 14-5-16.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "NSString+MessageDataExtension.h"
#import "SBJson.h"

@implementation NSString (MessageDataExtension)

+ (NSString *)getStrWithMessageDatas:(OriginData *)orgData, ...
{
    va_list args;
    va_start(args, orgData);
    
    NSMutableArray *insertArr = [[NSMutableArray alloc]init];
    NSDictionary *dataDic = [orgData getDic];
    [insertArr addObject:dataDic];
    OriginData *messageData;
    while (1) {
        messageData = va_arg(args, id);
        if (messageData == nil) {
            break;
        }
        NSDictionary *dataDic2 = [messageData getDic];
        [insertArr addObject:dataDic2];
    }
    va_end(args);
    
    NSString * result = [insertArr JSONRepresentation];
    RELEASE_SAFE(insertArr);
    return result;
}

@end
