//
//  SnailCommandReceiveTCMsg.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandReceiveTCMsg.h"

@implementation SnailCommandReceiveTCMsg

- (void)handleCommandData
{
    [self storeMessageAndSendItToOtherComponentWithMessageDic:self.bodyDic andMessageType:SessionTypeTempCircle];
}

@end
