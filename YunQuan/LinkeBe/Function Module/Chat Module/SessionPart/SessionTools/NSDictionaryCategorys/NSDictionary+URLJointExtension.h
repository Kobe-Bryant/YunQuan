//
//  NSDictionary+URLJointExtension.h
//  ql
//
//  Created by LazySnail on 14-8-28.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (URLJointExtension)

- (NSMutableDictionary *)jointUrlHeadStr:(NSString *)headStr forDicKeys:(NSString *)keys,...;

@end
