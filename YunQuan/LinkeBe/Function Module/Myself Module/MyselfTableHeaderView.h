//
//  MyselfTableHeaderView.h
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyselfTableHeaderView : UIView
@property (nonatomic, retain) UIButton *iconImageBtn;        //头像
@property (nonatomic, retain) UIImageView *sexImage;         //性别
@property (nonatomic, retain) UILabel     *personNameLable;  //个人名称
@property (nonatomic, retain) UILabel     *dataImproveLable; //公司名称
@property (nonatomic, retain) UIButton     *editBtn;    //职位
@end
