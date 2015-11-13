//
//  ContactViewController.h
//  LinkeBe
//
//  Created by Dream on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "ContactViewCell.h"
#import "ContactView.h"
#import "ContactModel.h"
#import "SBJson.h"
#import "PinYinForObjc.h"
#import "Circle_member_model.h"
#import "UIImageView+WebCache.h"
#import "MessageListData.h"
#import "CommonProgressHUD.h"
#import "MBProgressHUD.h"
#import "TempChatManager.h"
#import "PinYinSort.h"

@protocol ContactViewDelegate <NSObject>

- (void)callBackSelectedMembers :(NSMutableArray *)array;

@end

@interface ContactViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,TempChatManagerDelegate>

@property (nonatomic, assign) id<ContactViewDelegate>delegate;

//表视图
@property (nonatomic, retain) UITableView *mainTableView;

//搜索栏
@property (nonatomic, retain) UISearchBar *searchBar;

//搜索最终数据
@property (nonatomic, retain) NSMutableArray *searchResults;

//搜索控制器
@property (nonatomic, retain) UISearchDisplayController *searchControl;

//成员转化成model数据
@property (nonatomic, retain) NSMutableArray *modelArray;

//搜索 成员转化成model数据
@property (nonatomic, retain) NSMutableArray *modelSearchArray;

//选中的数据源
@property (nonatomic, retain) NSMutableArray *selectedArray;

//底部buttomView
@property (nonatomic, retain) ContactView *contectView;

@property (nonatomic,retain) MessageListData *listData;

//已经存在 在临时会话里面的人
@property (nonatomic,retain) NSArray *tempChatMemberArray;

@property (nonatomic, retain) MBProgressHUD *hudView;


@end
