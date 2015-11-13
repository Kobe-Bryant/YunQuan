//
//  SnailContactCommandObject.m
//  LinkeBe
//
//  Created by Dream on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailContactCommandObject.h"
#import "SnailSocketManager.h"
#import "SnailCommandFactory.h"
typedef enum {
    ErrorCodeSuccess,
    ErrorCodeFaild
}ErrorCode;

@implementation SnailContactCommandObject

- (void)handleCommandData {
    NSLog(@"创建临时会话 = %@",self.bodyDic);
    ErrorCode recode = [[self.bodyDic objectForKey:@"rcode"]intValue];
    switch (recode) {
        case ErrorCodeSuccess:
        {
//            long long locmid = [[self.bodyDic objectForKey:@"locmid"] longLongValue];
            long long tempChatId = [[self.bodyDic objectForKey:@"gid"] longLongValue];

        }
            break;
        case ErrorCodeFaild:
        {
            
        }
            break;
        default:
            break;
    }
}



@end
