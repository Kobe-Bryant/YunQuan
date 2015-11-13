//
//  DBOperate.m
//  Shopping
//
//  Created by zhu zhu chao on 11-3-22.
//  Copyright 2011 sal. All rights reserved.
//

#import "DBOperate.h"
#import "FileManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "DBConfig.h"
#import "Global.h"

@implementation DBOperate

//创建表
+ (BOOL)createUserDB
{
    //获取所有的表字典
    NSDictionary *tableDic = [DBConfig getDbTablesDic];
	NSString *dbFilePath=[FileManager getUserDBPath];
    
    return [self createTableWithDBPath:dbFilePath andTableDic:tableDic];
}

+ (BOOL) createApplicationDB
{
    //获取系统应用数据表
    NSDictionary *appDBTable = [DBConfig getApplicationConfigTableDic];
    NSString * appDBPath = [FileManager getFileDBPath:AppDataBaseName];
    
   return [self createTableWithDBPath:appDBPath andTableDic:appDBTable];
}

+ (BOOL)createTableWithDBPath:(NSString *)path andTableDic:(NSDictionary *)tableDic
{
    BOOL successJuger = YES;
    
    NSLog(@"dbFilePath:---------------- %@",path);
	FMDatabase *db=[FMDatabase databaseWithPath:path];
	if ([db open]) {
		[db setShouldCacheStatements:YES];
		for (id key in [tableDic allKeys])
        {
			NSString *checkTableSQL = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",key];
			FMResultSet *rs = [db executeQuery:checkTableSQL];
			if (![rs next]) {
				if (![db executeUpdate:[tableDic objectForKey:key]]) {
                    successJuger = NO;
                };
			}
		}
	}
	[db close];
    return successJuger;
}

@end
