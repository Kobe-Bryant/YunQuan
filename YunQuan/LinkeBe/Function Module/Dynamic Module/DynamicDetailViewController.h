//
//  DynamicDetailViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DynamicDetailViewDelegate <NSObject>

@optional
//动态删除回调
-(void) deleteDynamicCallBack:(int) publishId;

@optional
//赞、呵呵交互数据
-(void) heheZanCallBack;

@end

@interface DynamicDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView* commentTable;
    
    NSDictionary* _detailDic;
    
    NSMutableArray* commentArr;
    
    //页码
    int pageNum;
    //每页数目
    int pageSize;
    //总页数
    int pages;
    //总页数
    int totalCount;
    //时间错
    long long ts;
    //评论数目
    int commentNum;
    //zan,hehe
    int zanHeheSum;
}

@property(nonatomic,assign) id<DynamicDetailViewDelegate> delegate;

//键盘是否弹起
@property(nonatomic,assign) BOOL isShowKeyBoard;
//动态id
@property(nonatomic,assign) int publishId;
//动态详情
@property(nonatomic,retain) NSDictionary* detailDic;

@end
