//
//  BusinessCardViewController.h
//  LinkeBe
//
//  Created by Dream on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+NavigationBar.h"
#import "Global.h"
#import "PersionInfoView.h"
#import "FirstCell.h"
#import "SecondCell.h"
#import "ThirdCell.h"
#import "EditViewController.h"
#import "MajorCircleManager.h"
#import "UserModel.h"
#import "UIImageView+WebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "MobClick.h"

typedef NS_ENUM(NSInteger, BussinessType) {
    TabbarBussinessType,
    NormalBussinessType
};

@interface BusinessCardViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain) UITableView *businessCardTableView;

@property (nonatomic, assign) BussinessType bussinessType;

@property (nonatomic, retain) PersionInfoView *persionView;

@property (nonatomic, copy) NSString *nameStr; //谁的企业空间

@property (nonatomic,copy) NSString *test; //测试一下 签名自适应高度（网路数据来了再删除）
@end
