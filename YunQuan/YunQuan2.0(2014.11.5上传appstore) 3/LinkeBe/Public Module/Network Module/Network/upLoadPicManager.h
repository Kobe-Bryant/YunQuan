//
//  upLoadPicManager.h
//  ql
//
//  Created by yunlai on 14-7-19.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@interface upLoadPicManager : NSObject
//使用asiFormData
+(NSDictionary*) upLoadPicWithRequestDic:(NSMutableDictionary*) dic
                       dataList:(NSArray*) dataList
                     requestUrl:(NSString*) requestUrl;

//connect
+(NSDictionary*) upLoadPicWithPara:(NSMutableDictionary*) param
                      dataList:(NSArray*) dataList
                    requestUrl:(NSString*) requestUrl;

//2.0
+(NSDictionary*) NewUpLoadPicWithPara:(NSMutableDictionary *)param dataList:(NSArray *)dataList requestUrl:(NSString *)requestUrl;

@end
