//
//  NSString+extra.m
//  TestWebtrends
//
//  Created by pingan_tiger on 11-4-29.
//  edit by ronghai_zhengzy on 11-9-28.
//  Copyright 2011 pingan. All rights reserved.
//

#import "Webtrends+extra.h"

@implementation NSObject (webtrends)


NSString * dcEncode_UTF8(NSString * encodeStr) {
    NSString * preprocessedString = (NSString * ) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef) encodeStr, CFSTR(""), kCFStringEncodingUTF8);
    NSString * resultStr = [(NSString * ) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) preprocessedString, nil, nil, kCFStringEncodingUTF8) autorelease];
    //resultStr = [resultStr stringByReplacingOccurrencesOfString: @"%" withString: @"%25"];
    [preprocessedString release];
    return resultStr;
}

NSString * dcEncode_2_UTF8(NSString * encodeStr) {
    NSString * preprocessedString = (NSString * ) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef) encodeStr, CFSTR(""), kCFStringEncodingUTF8);
    NSString * resultStr = [(NSString * ) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) preprocessedString, nil, nil, kCFStringEncodingUTF8) autorelease];
    resultStr = [resultStr stringByReplacingOccurrencesOfString: @"%" withString: @"%25"];
    [preprocessedString release];
    return resultStr;
}

NSString * dcEncode_GB2312(NSString * encodeStr) {
    NSString * preprocessedString = (NSString * ) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef) encodeStr, CFSTR(""), kCFStringEncodingGB_18030_2000);
    NSString * resultStr = [(NSString * ) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) preprocessedString, nil, nil, kCFStringEncodingGB_18030_2000) autorelease];
    //resultStr = [resultStr stringByReplacingOccurrencesOfString: @"%" withString: @"%25"];
    [preprocessedString release];
    return resultStr;
}

@end
