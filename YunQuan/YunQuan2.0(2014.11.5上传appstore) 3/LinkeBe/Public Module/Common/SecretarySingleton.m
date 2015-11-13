//
//  SecretorySingleton.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SecretarySingleton.h"

@implementation SecretarySingleton

+ (SecretarySingleton *)shareSecretary
{
    static SecretarySingleton * secretary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        secretary = [[self alloc]init];
    });
    return secretary;
}


@end
