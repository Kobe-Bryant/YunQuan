//
//  CicleListCell.h
//  LinkeBe
//
//  Created by Dream on 14-9-13.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CicleListCell : UITableViewCell

@property (nonatomic, assign) long long userID;
@property (nonatomic, retain) UILabel *nameLable;
@property (nonatomic, retain) UILabel *companyLable; //公司名
@property (nonatomic, retain) UILabel *positionLable; //职位
@property (nonatomic, retain) UIImageView *listNameImage; //人物头像
@property (nonatomic, retain) UIButton *sendBtn;   //邀请button
@property (nonatomic, retain) UILabel *inviteLable; //职位

@end
