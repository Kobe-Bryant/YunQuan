//
//  SecondCell.h
//  LinkeBe
//
//  Created by Dream on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondCell : UITableViewCell{
   
}

@property (nonatomic, retain) UIImageView *headImage;      //公司图标
@property (nonatomic, retain) UILabel     *companyLable;  //公司名
@property (nonatomic, retain) UILabel     *countLable;    //浏览量
@property (nonatomic, retain) UIImageView *arrawImage;      //箭头

@property (nonatomic ,retain) UIButton *dredgeBtn;
@property (nonatomic ,retain)  UILabel *tip;
//未开通公司轻APP
- (void)noDredgeCompanyLightApp;
//开通liveApp
-(void)openCompanyLightApp;
@end
