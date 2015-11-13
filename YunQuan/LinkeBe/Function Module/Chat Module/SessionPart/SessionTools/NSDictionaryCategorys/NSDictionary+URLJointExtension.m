//
//  NSDictionary+URLJointExtension.m
//  ql
//
//  Created by LazySnail on 14-8-28.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "NSDictionary+URLJointExtension.h"

@implementation NSDictionary (URLJointExtension)

- (NSMutableDictionary *)jointUrlHeadStr:(NSString *)headStr forDicKeys:(NSString *)keys, ...
{
    va_list args;
    va_start(args, keys);
    
    NSString * nextKey = keys;
    NSMutableDictionary * mutiDic = [NSMutableDictionary dictionaryWithDictionary:self];
    
    while (1) {
        if (nextKey == nil) {
            break;
        }
        NSString * contentUrl = [mutiDic objectForKey:nextKey];
        if (contentUrl != nil && ![contentUrl isEqualToString:@""]) {
            NSString * wholeUrlStr = [NSString stringWithFormat:@"%@%@",headStr,contentUrl];
            [mutiDic removeObjectForKey:nextKey];
            [mutiDic setObject:wholeUrlStr forKey:nextKey];
        }
        nextKey = va_arg(args, id);
    }
    return mutiDic;
}

@end
