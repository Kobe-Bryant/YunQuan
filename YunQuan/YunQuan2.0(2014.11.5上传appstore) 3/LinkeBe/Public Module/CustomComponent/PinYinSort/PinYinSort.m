//
//  PinYinSort.m
//  LinkeBe
//
//  Created by Dream on 14-10-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PinYinSort.h"

@implementation PinYinSort

+ (NSMutableDictionary *)accordingFirstLetterFromPinYin:(NSArray *)array {
    NSMutableDictionary* mutDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if ([array count]) {
        for (NSDictionary *dic in array) {
             NSString *key = nil;
            NSString *str = [dic objectForKey:@"pinyin"];
            if (str.length > 0 && ![str isEqualToString:@""]) {
                NSString* tempKey = [[dic objectForKey:@"pinyin"] substringWithRange:NSMakeRange(0, 1)];
                key = [tempKey uppercaseString];

            }
            // 加入key异常判断 add by snail
            if (key!=nil) {
                if ([[mutDic allKeys] containsObject:key]) {
                    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                    NSMutableArray *tmpArr = [mutDic objectForKey:key];
                    [arr addObjectsFromArray:tmpArr];
                    [arr addObject:dic];
                    [mutDic setObject:arr forKey:key];
                } else {
                    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                    [arr addObject:dic];
                    [mutDic setObject:arr forKey:key];
                }
            }
        }
        
        //对数组进行全拼排序
        for (NSString* key in [mutDic allKeys]) {
            NSArray* arr = [mutDic objectForKey:key];
            if (arr.count > 1) {
                NSArray* newArr = [self sortRealNameWith:arr];
                [mutDic setObject:newArr forKey:key];
            }
            
        }
    }
      return mutDic;
}

+(NSArray*) sortRealNameWith:(NSArray*) arr{
    NSArray* newArr = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1,id obj2){
        
        NSDictionary* dic1 = (NSDictionary*)obj1;
        NSDictionary* dic2 = (NSDictionary*)obj2;
        
        NSString* str1 = [dic1 objectForKey:@"pinyin"];
        NSString* str2 = [dic2 objectForKey:@"pinyin"];
        
        return [str1 compare:str2];
    }];
    return newArr;
}

@end
