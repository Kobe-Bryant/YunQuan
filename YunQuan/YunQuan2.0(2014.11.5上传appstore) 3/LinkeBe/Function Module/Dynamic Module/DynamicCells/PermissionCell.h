//
//  PermissionCell.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PermissionCellDelegate <NSObject>

//点击聊聊
-(void) chatClickWithUserInfo:(NSDictionary*) userInfo;

//头像
-(void) headClickWithUserId:(NSDictionary*) userInfo;

@end

@interface PermissionCell : UITableViewCell

@property(nonatomic,assign) id<PermissionCellDelegate> delegate;

@property(nonatomic,assign) int userId;
@property(nonatomic,retain) NSDictionary* dataDic;
@property(nonatomic,assign) int orgUserId;

@property(nonatomic,retain) UIImageView* headImageView;
@property(nonatomic,retain) UILabel* nameLab;
@property(nonatomic,retain) UILabel* positionLab;
@property(nonatomic,retain) UILabel* companylab;

//填充数据
-(void) writePermissionDataInCell:(NSDictionary*) dic;

@end
