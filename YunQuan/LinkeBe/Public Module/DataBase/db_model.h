//
//  DBModel.h
//  cw
//
//  Created by siphp on 13-8-12
//

#import <Foundation/Foundation.h>
#import "FileManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@class FMDatabase;

@interface db_model : NSObject {
    
    FMDatabase *db;
    NSString *dbFilePath;
    NSString *tableName;
    NSString *_where;
    NSString *_orderBy;
    NSString *_orderType;
    int _limit;
    
}

@property (nonatomic, retain) NSString *where;
@property (nonatomic, retain) NSString *orderBy;
@property (nonatomic, retain) NSString *orderType;
@property (nonatomic, assign) int limit;

/*
 * 注意这两个方法会在内部释放实例变量
 */
+ (BOOL)updateDataWithModel:(db_model *)listGeter withDic:(NSDictionary *)dic;

+ (BOOL)deleteAllDataWithModel:(db_model *)listGeter;

//获取列表 支持条件 条数 排序
-(NSMutableArray *)getList;

//插入数据 成功则返回插入ID 失败则返回 0
-(int)insertDB:(NSDictionary *)data;

//更新记录 支持条件更新
-(BOOL)updateDB:(NSDictionary *)data;

//删除记录 支持条件更新
-(BOOL)deleteDBdata;

//执行sql语句 用于查询
-(NSMutableArray *)querSelectSql:(NSString *)sql;

//执行sql语句 用于更新,删除
-(BOOL)queryUpdateSql:(NSString *)sql;

//add by vincent  2014.7.5 分页加载数据
-(NSMutableArray *)fromPageNumber:(NSInteger)fromPageNumber pageNumber:(NSInteger)pageNumber;
@end
