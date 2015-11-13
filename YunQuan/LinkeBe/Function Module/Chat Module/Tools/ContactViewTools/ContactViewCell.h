//
//  ContactViewCell.h
//  LinkeBe
//
//  Created by Dream on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactViewCell : UITableViewCell

@property (nonatomic, retain) UIImageView *selectImage;
@property (nonatomic, retain) UILabel *nameLable;
@property (nonatomic, retain) UILabel *companyLable; //公司名
@property (nonatomic, retain) UILabel *positionLable; //职位
@property (nonatomic, retain) UIImageView *listNameImage; //人物头像

@end
