//
//  NSString+emoji.h
//  LinkeBe
//
//  Created by yunlai on 14-10-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (emoji)

+(NSString*) replaceEmojiWithCode:(NSString*) string;

+(BOOL) isEmojiWithCode:(NSString*) string;

@end
