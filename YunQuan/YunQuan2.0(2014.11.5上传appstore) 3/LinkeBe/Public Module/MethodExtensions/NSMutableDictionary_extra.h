//
//  NSMutableDictionary_extra.h
//  PA_Ipad
//
//  Created by pingan_tiger on 11-5-3.
//  Copyright 2011 pingan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (extra)


//根据key值的到字典中的object
- (id)getObjectByKey:(NSString*)key;

//根据key值的到字典中的类型匹配的object
- (id)getObjectByKey:(NSString*)key targetClass:(Class)clazz;

//根据key值得到字符串，如为空则返回@“”
- (id)getStringByKey:(NSString*)key;

//根据key值把字典中的list字典转换成数组
- (NSMutableArray*)getArrayByString:(NSString*)string;

// 排序
- (NSArray *)allSortedKeys;

@end
