//
//  emoji.h
//  emoji
//
//  Created by chenxj on 2013-09-13
//  Copyright (c) 2013 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface emoji : NSObject
+ (NSMutableArray *)getEmoji;
+ (NSMutableArray *)getStringEmoji;
+ (NSDictionary *)getCustomEmoji;
@end
