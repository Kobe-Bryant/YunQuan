//
//  SnailRequestGet.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailRequestGet.h"

@implementation SnailRequestGet

@synthesize requestType = m_requestType;

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_requestType = LinkedBe_GET;
    }
    return self;
}

@end
