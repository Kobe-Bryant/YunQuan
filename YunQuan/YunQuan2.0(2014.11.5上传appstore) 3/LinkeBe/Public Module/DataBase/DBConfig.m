//
//  DBConfig.m
//  cw
//
//  Created by siphp on 13-8-12.
//
//

#import "DBConfig.h"

@implementation DBConfig

//所有数据表
+(NSDictionary *)getDbTablesDic
{
    //    时间戳 TimeStamp_model
    NSString* t_TimeStamp = @"t_TimeStamp";
    NSString* t_TimeStamp_sql = @"create table t_TimeStamp(type INTEGER,timestamp LONG LONG)";
//////////////-------动态--------///////////////
    //动态卡片表
    NSString* t_Dynamic_card = @"t_Dynamic_card";
    NSString* t_Dynamic_card_sql = @"create table t_Dynamic_card(id INTEGER PRIMARY KEY,type INTEGER,createdTime INTEGER,content TEXT,userId INTEGER,ts INTEGER DEFAULT 0)";
    
    //页码表
    NSString* t_Dynamic_page = @"t_Dynamic_page";
    NSString* t_Dynamic_page_sql = @"create table t_Dynamic_page(type INTEGER PRIMARY KEY,ts INTEGER,pageNumber INTEGER,pageSize INTEGER,totalCount INTEGER,pages INTEGER)";
    
    //发布权限
    NSString* t_Dynamci_permission = @"t_Dynamci_permission";
    NSString* t_Dynamci_permission_sql = @"create table t_Dynamci_permission(orgUserId INTEGER PRIMARY KEY,content TEXT,status INTEGER)";
//////////////-------动态--------///////////////
    
    // 二维码扫描记录表Scan_history_model
    NSString *t_Scan_history = @"t_scan_history";
    NSString *t_Scan_history_sql = @"create table t_scan_history(id INTEGER PRIMARY KEY,type TEXT,info TEXT,result TEXT,created INTEGER)";

    //三级组织表
    NSString *t_Cicle_org = @"t_Cicle_org";
    NSString *t_Cicle_org_sql = @"create table t_Cicle_org(id INTEGER PRIMARY KEY,name TEXT,parentId INTEGER,catPic TEXT,position INTEGER,pinyin TEXT,createdTime TEXT,updatedTime TEXT,disabled INTEGER,membersNumber INTEGER DEFAULT 0,ovpId INTEGER,userId INTEGER)";
    
    //所有组织成员 org userId  Cicle_member_list_model
    NSString *t_Cicle_member_list = @"t_Cicle_member_list";
    NSString *t_Cicle_member_list_sql = @"create table t_Cicle_member_list(orgId INTEGER,userId INTEGER)";
    
    //组织成员列表
    NSString *t_Circle_member = @"t_Circle_member";
    NSString *t_Circle_member_sql = @"create table t_Circle_member(userId INTEGER PRIMARY KEY,orgId INTEGER,orgUserId INTEGER,portrait TEXT DEFAULT NULL,state INTEGER,realname TEXT,pinyin TEXT,companyName TEXT DEFAULT NULL,level INTEGER,sex TEXT DEFAULT NULL,createdTime TEXT,updatedTime TEXT,mobile TEXT,companyRole TEXT)";
    
    //临时会话详情表  TempChat_list_model
    NSString *t_TempChat_list = @"t_TempChat_list";
    NSString *t_TempChat_list_sql = @"create table t_TempChat_list(id INTEGER PRIMARY KEY,name TEXT,orgUserId INTEGER,portrait TEXT,createdTime INTEGER,updatedTime INTEGER,userId INTEGER,orgId INTEGER,members TEXT,ts INTEGER,sendedMessageTag INTEGER)";
    
    // 个人信息   Userinfo_model.h
    NSString *t_Userinfo = @"t_Userinfo";
    NSString *t_Userinfo_sql = @"create table t_Userinfo(orgUserId INTEGER PRIMARY KEY,content TEXT)";
    
    // 开通的公司 OpenCompanyUsers_model.h
    NSString *t_OpenCompanyUsers = @"t_OpenCompanyUsers";
    NSString *t_OpenCompanyUsers_sql = @"create table t_OpenCompanyUsers(id INTEGER PRIMARY KEY,content TEXT)";
    
//    与我相关 RelevantMe_model
    NSString *t_RelevantMe = @"t_RelevantMe";
    NSString *t_RelevantMe_sql = @"create table t_RelevantMe(id INTEGER PRIMARY KEY,content TEXT)";
    
//    企业开通的liveapp Companie_LiveApp_model
    NSString *t_Companie_LiveApp = @"t_Companie_LiveApp";
    NSString *t_Companie_LiveApp_sql = @"create table t_Companie_LiveApp(content TEXT)";
    
    NSString *t_MessageListTable = @"t_MessageListTable";
    NSString *t_MessageListTable_sql = @"create table t_MessageListTable(object_id INTEGER ,session_type INTEGER,portrait Text,title Text,latest_message Text,unread_count INTEGER)";
    
    NSString *t_MessageHistoryRecordTable = @"t_MessageHistoryRecordTable";
    NSString *t_MessageHistoryRecordTable_sql = @"create table t_MessageHistoryRecordTable(id INTEGER PRIMARY KEY,object_id INTEGER,session_type INTEGER,operation_type INTEGER,spkinfo Text,msg Text,time INTEGER,mid INTEGER,show_time BOOL,sendStatus INTEGER)";
    
    NSString *t_SecretaryOrgInfoTable = @"t_SecretaryOrgInfoTable";
    NSString *t_SecretaryOrgInfoTable_sql = @"create table t_SecretaryOrgInfoTable (uid INTEGER PRIMARY KEY, realname TEXT,portrait TEXT,type INTEGER,orgUserId INTEGER)";
    
    //自定义表情商店信息
    NSString *t_emoticon_store_info = @"t_emoticon_store_info";
    NSString *t_emoticon_store_info_sql = @"create table t_emoticon_store_info(ts INTEGER,thumbnails TEXT,resPath TEXT)";
    
    //自定义表情商店列表
    NSString *t_emoticon_list = @"t_emoticon_list";
    NSString *t_emoticon_list_sql = @"create table t_emoticon_list(title TEXT,subtitle TEXT,packetPath TEXT,packetName TEXT,icon TEXT,chatIcon TEXT,price INTEGER,status INTEGER,packetId INTEGER PRIMARY KEY,createdTime INTEGER,updatedTime INTEGER,enabled INTEGER)";
    
    //自定义表情详情信息
    NSString *t_emoticon_detail_info = @"t_emoticon_detail_info";
    NSString *t_emoticon_detail_info_sql = @"create table t_emoticon_detail_info(description TEXT,status INTEGER,emoticonId INTEGER,createdTime INTEGER,updatedTime INTEGER, thumbnails TEXT,ts INTEGER,resPath TEXT,enabled INTEGER,packetPath TEXT,packetName TEXT)";
    
    //自定义表情项列表 （每个表情自己的属性列表）
    NSString *t_emoticon_item_list = @"t_emoticon_item_list";
    NSString *t_emoticon_item_list_sql = @"create table t_emoticon_item_list(id INTEGER PRIMARY KEY,title TEXT,code TEXT,packetId INTEGER,previewIcon TEXT,emoticonPath TEXT,createdTime INTEGER,updatedTime INTEGER,enabled INTEGER)";
    
    //消息设置表
    NSString* t_message_push = @"t_message_push";
    NSString* t_message_push_sql = @"create table t_message_push(userId INTEGER PRIMARY KEY,chatStatus INTEGER,updateStatus INTEGER,replayStatus INTEGER)";
    
    NSDictionary *tableDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              t_TimeStamp_sql,t_TimeStamp,
                              t_Scan_history_sql,t_Scan_history,
                              t_MessageListTable_sql,t_MessageListTable,
                              t_MessageHistoryRecordTable_sql,t_MessageHistoryRecordTable,
                              t_Dynamic_card_sql,t_Dynamic_card,
                              t_Dynamic_page_sql,t_Dynamic_page,
                              t_Dynamci_permission_sql,t_Dynamci_permission,
                              t_Cicle_org_sql,t_Cicle_org,
                              t_Cicle_member_list_sql,t_Cicle_member_list,
                              t_Circle_member_sql,t_Circle_member,
                              t_TempChat_list_sql,t_TempChat_list,
                              t_Userinfo_sql,t_Userinfo,
                              t_OpenCompanyUsers_sql,t_OpenCompanyUsers,
                              t_RelevantMe_sql,t_RelevantMe,
                              t_SecretaryOrgInfoTable_sql,t_SecretaryOrgInfoTable,
                              t_emoticon_list_sql,t_emoticon_list,
                              t_emoticon_store_info_sql,t_emoticon_store_info,
                              t_emoticon_item_list_sql,t_emoticon_item_list,
                              t_emoticon_detail_info_sql,t_emoticon_detail_info,
                              t_Companie_LiveApp_sql,t_Companie_LiveApp,
                              t_message_push_sql,t_message_push,
                              nil];
    return tableDic;
}

+ (NSDictionary *)getApplicationConfigTableDic
{
    //所有用户列表
    NSString * t_whole_users = @"t_whole_users";
    NSString * t_whole_users_sql = @"create table t_whole_users(user_account_name TEXT PRIMARY KEY, all_org_numbers TEXT,previous_choose_org INTEGER)";
    
    //------apns 表------//
    //版本信息表
    NSString* t_upgrade = @"t_upgrade";
    NSString* t_upgrade_sql = @"create table t_upgrade(ver INTEGER,url TEXT,score_url TEXT,remark TEXT)";
    
    // 选择组织表
    NSString *t_chooseOrg = @"t_chooseOrg";
    NSString *t_chooseOrg_sql = @"create table t_chooseOrg(id INTEGER PRIMARY KEY,catPic TEXT,orgName TEXT,orgUserId TEXT,isDisabled TEXT,welcome_id TEXT,welcome_userId TEXT,welcome_orgId TEXT,welcome_content TEXT,welcome_luokuan TEXT,welcome_btn TEXT,welcome_pic TEXT);";
    
    //小秘书文本
    NSString* t_secret_message = @"t_secret_message";
    NSString* t_secret_message_sql = @"create table t_secret_message(type INTEGER,message TEXT)";
    
    NSDictionary * appConfigTables = [NSDictionary dictionaryWithObjectsAndKeys:
                                      t_whole_users_sql,t_whole_users,
                                      t_upgrade_sql,t_upgrade,
                                      t_chooseOrg_sql,t_chooseOrg,
                                      t_secret_message_sql,t_secret_message,
                                      nil];
    return appConfigTables;
}

@end
