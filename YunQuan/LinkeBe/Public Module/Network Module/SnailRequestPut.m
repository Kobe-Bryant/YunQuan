//
//  SnailRequestPut.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-30.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SnailRequestPut.h"

@implementation SnailRequestPut

@synthesize requestType = m_requestType;

- (instancetype)init
{
    self = [super init];
    if (self) {
        m_requestType = LinkedBe_PUT;
    }
    return self;
}

@end
