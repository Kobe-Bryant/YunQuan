//
//  URLHelper.h (V 1.0)
//  jsTest
//
//  Created by MgenLiu on 13-8-19.
//  Copyright (c) 2013年 MgenLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLHelper : NSObject

//http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string/3426140#3426140
//对字符串进行URL编码
+ (NSString *)StringEncode:(NSString*)str;

//http://stackoverflow.com/questions/7920071/how-to-url-decode-in-ios-objective-c
//对字符串进行URL解码
+ (NSString *)StringDecode:(NSString*)str;

//URL编码
+ (NSString *)URLEncode:(NSString*)baseUrl data:(NSDictionary*)dictionary;

//URL解码
+ (NSArray *)URLDecode:(NSString *)url;


@end
