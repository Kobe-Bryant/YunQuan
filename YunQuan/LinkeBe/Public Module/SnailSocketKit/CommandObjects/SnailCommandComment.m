//
//  SnailCommandCommentObject.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-27.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailCommandComment.h"

@implementation SnailCommandComment

- (void)handleCommandData
{
    if (self.bodyDic) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RelateMeComment" object:self.bodyDic];
    }
}

@end
