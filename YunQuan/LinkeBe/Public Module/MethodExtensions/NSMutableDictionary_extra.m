//
//  NSMutableDictionary_extra.m
//  PA_Ipad
//
//  Created by pingan_tiger on 11-5-3.
//  Copyright 2011 pingan. All rights reserved.
//

#import "NSMutableDictionary_extra.h"


@implementation NSDictionary (extra)


//根据key值的到字典中的object
- (id)getObjectByKey:(NSString*)key {
	NSArray *array = [key componentsSeparatedByString:@"/"];
	NSDictionary *dic = self;
	for (int i=0; i<[array count]-1; i++) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        NSDictionary *temp = [dic objectForKey:[array objectAtIndex:i]];
        if ([temp isKindOfClass:[NSDictionary class]]) {
            dic = temp;
        }
        else {
            return nil;
        }
	}
    
    if ([dic isKindOfClass:[NSDictionary class]]) {
        return [dic objectForKey:[array objectAtIndex:[array count]-1]];
    }
    else {
        return nil;
    }
}

//根据key值的到字典中的类型匹配的object
- (id)getObjectByKey:(NSString*)key targetClass:(Class)clazz {
    id _taget = [self getObjectByKey:key];
	if ([_taget isKindOfClass:clazz]) {
        return _taget;
    }
	return nil;
}

/*
 根据key值得到字符串，如为空则返回@“”
 */
- (id)getStringByKey:(NSString*)key {
	NSArray *array = [key componentsSeparatedByString:@"/"];
	NSDictionary *dic = self;
	for (int i=0; i<[array count]-1; i++) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return @"";
        }
        
        NSDictionary *temp = [dic objectForKey:[array objectAtIndex:i]];
        if ([temp isKindOfClass:[NSDictionary class]]) {
            dic = temp;
        }
        else {
            return @"";
        }
	}
	NSString *temp = [dic objectForKey:[array objectAtIndex:[array count]-1]];
	if (!temp) {
		temp = @"";
	}
	return temp;
}

/*
 根据key值把字典中的list字典转换成数组
 使用方法：NSArray *array = [self getArrayByString:@"Data/responseBody/eventList"];
 */
- (NSMutableArray*)getArrayByString:(NSString*)string  {
    NSDictionary *dic = [self getObjectByKey:string];
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSArray *keys = [dic allSortedKeys];
        for (int i=0; i<[keys count]; i++) {
            NSString *key = [keys objectAtIndex:i];
            [array addObject:[dic objectForKey:key]];
        }
    }
	return [array autorelease];
}

/*
对key进行排序，替代[dic allKeys]，对keys进行排序
*/
- (NSArray *)allSortedKeys {
	if ([self objectForKey:@"Item"]) {
		NSMutableArray *array = [NSMutableArray array];
		[array addObject:@"Item"];
		for (int i=1; i<[[self allValues] count]; i++) {
			[array addObject:[NSString stringWithFormat:@"Item%d", i]];
		}
		return array;
	}
	else if ([self objectForKey:@"item"]) {
		NSMutableArray *array = [NSMutableArray array];
		[array addObject:@"item"];
		for (int i=1; i<[[self allValues] count]; i++) {
			[array addObject:[NSString stringWithFormat:@"item%d", i]];
		}
		return array;
	}
	return [self allKeys];
}

+ (NSMutableArray*)getArrayByData:(NSDictionary*)dic {
	if (![dic isKindOfClass:NSClassFromString(@"NSDictionary")] || ![dic isKindOfClass:NSClassFromString(@"NSMutableDictionary")]) {
		return [NSMutableArray array];
	}
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSArray *keys = [dic allSortedKeys];
	for (int i=0; i<[keys count]; i++) {
		NSString *key = [keys objectAtIndex:i];
		[array addObject:[dic objectForKey:key]];
	}
	return [array autorelease];
}
@end
