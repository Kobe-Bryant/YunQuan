//
//  SnailCommandTCQuitACK.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandTCQuitACK.h"
#import "TempChatManager.h"

@implementation SnailCommandTCQuitACK

- (void)handleCommandData
{
    [[TempChatManager shareManager]quitTempCircleSuccessWithLocalID:self.serialNumber];
}

@end
