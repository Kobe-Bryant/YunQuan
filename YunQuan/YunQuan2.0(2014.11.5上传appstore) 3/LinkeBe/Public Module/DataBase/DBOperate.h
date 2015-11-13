//
//  DBOperate.h
//  cw
//
//  Created by chenxj on 13-08-14.
//  Copyright 2013 yunlai All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBOperate : NSObject {
    
}

//创建用户数据库
+(BOOL)createUserDB;

//创建应用系统表
+ (BOOL) createApplicationDB;


@end
