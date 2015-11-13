//
//  SnailRequestPostObject.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailRequestPostObject.h"

@implementation SnailRequestPostObject

@synthesize requestType = m_requestType;

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        m_requestType = LinkedBe_POST;
    }
    return self;
}

- (void)dealloc
{
    self.postData = nil;
    self.postDataArr = nil;
    [super dealloc];
}

@end
