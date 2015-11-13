//
//  NSString+extra.h
//  TestWebtrends
//
//  Created by pingan_tiger on 11-4-29.
//  Copyright 2011 pingan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (extra)

NSString * dcEncode_UTF8(NSString * encodeStr);
NSString * dcEncode_2_UTF8(NSString * encodeStr);
NSString * dcEncode_GB2312(NSString * encodeStr);

@end
