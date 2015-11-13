//
//  NSString+MD5.m
//  CommunityAPP
//
//  Created by Stone on 14-3-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MD5)


- (NSString *)md5 {
    
    NSString *md5string = [NSString string];
    const char *cStr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)[self length], buffer);
    
    int i;
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        md5string = [md5string stringByAppendingString:[NSString stringWithFormat:@"%02x", buffer[i]]];
    
    return md5string;
}

- (NSString *)uppercaseMd5;
{
    return [[self md5] uppercaseString];
}


@end
