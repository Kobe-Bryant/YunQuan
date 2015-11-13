//
//  DBConfig.h
//  cw
//
//  Created by siphp on 13-8-12.
//
//

#import <Foundation/Foundation.h>

@interface DBConfig : NSObject {
    
}

//所有数据表
+ (NSDictionary *)getDbTablesDic;

//构建应用系统数据表
+ (NSDictionary *)getApplicationConfigTableDic;

@end
