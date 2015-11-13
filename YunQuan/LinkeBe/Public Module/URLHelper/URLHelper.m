//
//  URLHelper.m (V 1.0)
//  jsTest
//
//  Created by MgenLiu on 13-8-19.
//  Copyright (c) 2013年 MgenLiu. All rights reserved.
//

#import "URLHelper.h"

@implementation URLHelper

+ (NSString *)StringEncode:(NSString*)str
{
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[str UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (NSString *)StringDecode:(NSString*)str
{
    return [[str stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)URLEncode:(NSString*)baseUrl data:(NSDictionary*)dictionary
{
    NSString *url = baseUrl;
    if(url.length > 0)
    {
        url = [url stringByAppendingString:@"?"];
    }
    
    BOOL isFirst = YES;
    for(NSString *key in dictionary.allKeys)
    {
        if(isFirst)
        {
            isFirst = NO;
        }
        else
        {
            url = [url stringByAppendingString:@"&"];
        }
        url = [url stringByAppendingFormat:@"%@=%@", [self StringEncode:key], [self StringEncode:[dictionary objectForKey:key]]];
    }
    return url;
}

+ (NSArray *)URLDecode:(NSString *)url
{
    NSRange range = [url rangeOfString:@"?"];
    if(range.location == NSNotFound)
    {
        return @[url, [NSNull null]];
    }
    
    NSString *baseUrl = [url substringToIndex:range.location - 1];
    NSString *dataUrl = [url substringFromIndex:range.location + 1];
    
    NSArray *parameters = [dataUrl componentsSeparatedByString:@"&"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:parameters.count];
    for(NSString *pa in parameters)
    {
        NSArray *pair = [pa componentsSeparatedByString:@"="];
        NSString *key = [self StringDecode:[pair objectAtIndex:0]];
        NSString *val = [self StringDecode:[pair objectAtIndex:1]];
        
        [dic setValue:val forKey:key];
    }
    return @[baseUrl, dic];
}

@end
