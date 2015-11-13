//
//  SnailNetWorkManager.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailRequestObject.h"
#import "HttpRequest.h"

@class SnailRequestPostObject;

@interface SnailNetWorkManager : NSObject

+ (SnailNetWorkManager *)shareManager;

- (void)sendHttpRequest:(SnailRequestObject *)requestObject fromDelegate:(id)delegate andParam:(NSMutableDictionary *)parameter;

@end
