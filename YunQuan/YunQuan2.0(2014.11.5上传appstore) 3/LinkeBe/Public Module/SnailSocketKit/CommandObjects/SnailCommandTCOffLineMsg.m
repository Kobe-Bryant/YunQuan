//
//  SnailCommandTCHistoryMsg.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandTCOffLineMsg.h"

@implementation SnailCommandTCOffLineMsg

- (void)handleCommandData
{
    [self storeHistoryMsgAndSendACKWithSessionType:SessionTypeTempCircle];
}

@end
