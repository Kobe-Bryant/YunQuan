//
//  SnailCommandDynamicNotifyObject.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandDynamicNotify.h"

#import "DynamicIMManager.h"

@implementation SnailCommandDynamicNotify

- (void)handleCommandData
{
    //有新动态,红点提醒
    [[DynamicIMManager shareManager] receiveNewDynamicNotify:nil];
}

@end
