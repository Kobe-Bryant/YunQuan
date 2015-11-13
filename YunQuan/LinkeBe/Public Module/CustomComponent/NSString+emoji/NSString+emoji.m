//
//  NSString+emoji.m
//  LinkeBe
//
//  Created by yunlai on 14-10-29.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "NSString+emoji.h"
#import "RegexKitLite.h"

@implementation NSString (emoji)

+(NSString*) replaceEmojiWithCode:(NSString*) string{
    NSString* newStr = [string stringByReplacingOccurrencesOfRegex:@"[\u2600-\u27ff]|[\u231A\u231B]|[\u23E9-\u23EC]|[\u23F0\u23F3\u2614\u2615]|[\u2648-\u2653]|[\u267F\u2693\u26A1\u26AA\u26AB]|[\u26B3-\u26BD]|[\u26BF-\u26E1]|[\u26E3-\u26FF]|[\u2705\u270A\u270B\u2728\u274C\u274E\u2753\u2757\u2795\u2796\u2797\u27B0\u27BF]" withString:@" "];
    return newStr;
}

+(BOOL) isEmojiWithCode:(NSString*) string{
    return [string isMatchedByRegex:@"[\u2600-\u27ff]|[\u231A\u231B]|[\u23E9-\u23EC]|[\u23F0\u23F3\u2614\u2615]|[\u2648-\u2653]|[\u267F\u2693\u26A1\u26AA\u26AB]|[\u26B3-\u26BD]|[\u26BF-\u26E1]|[\u26E3-\u26FF]|[\u2705\u270A\u270B\u2728\u274C\u274E\u2753\u2757\u2795\u2796\u2797\u27B0\u27BF]"];
}

@end
