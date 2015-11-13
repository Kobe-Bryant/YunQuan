//
//  SnailSocketManager.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailCommandObject.h"

@interface SnailSocketManager : NSObject

+ (void)sendCommandObject:(SnailCommandObject *)commandObj;

+ (void)recieveSocketData:(NSData *)data;

+ (BOOL)isConnected;

+ (void)breakConnect;

+ (void)connectToServer;

@end
