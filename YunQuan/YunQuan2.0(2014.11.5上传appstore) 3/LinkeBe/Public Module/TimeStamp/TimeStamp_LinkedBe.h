//
//  TimeStamp_LinkedBe.h
//  LinkeBe
//
//  Created by yunlai on 14-9-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

/*
 *TimeStamp_LinkedBe 针对当前的项目中用到的所有的时间戳，LinkedBe_后面的表示某个模块
 *的标记，例如如果是Login的话就是 LinkedBe_Login_TimeStamp,当前数据库插入当前数据的时候
 *需要把type（枚举类型）以及当前时间戳的值传进去。
 *"create table t_TimeStamp(type INTEGER,ts long)" type 指类型，
 */
//三级组织
typedef enum{
    LinkedBe_ORG_TIMESTAMP            = 0,
}TimeStamp_LinkedBe; //

#ifndef LinkeBe_TimeStamp_LinkedBe_h
#define LinkeBe_TimeStamp_LinkedBe_h



#endif
