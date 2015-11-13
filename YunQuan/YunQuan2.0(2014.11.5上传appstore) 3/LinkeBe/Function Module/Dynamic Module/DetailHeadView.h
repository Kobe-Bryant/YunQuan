//
//  DetailHeadView.h
//  LinkeBe
//
//  Created by yunlai on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DynamicCommon.h"

#import "PopoverView.h"

#import "DynamicListManager.h"

@protocol DetailHeaderDelegate <NSObject>

//头像名字点击
-(void) touchHeader;

//评论
-(void) commentButtonClick;

//快速评论
-(void) optionButtonClickWithType:(int) type;

//删除动态
-(void) deleteButtonClickWith:(int) publishId;

@optional
//点击图片
-(void) midImageTouch:(UIImageView*) imageV;

//参与／我有我要点击
-(void) roundButtonClickWithType:(DynamicType) dyType sender:(UIButton*) sender;

@end

@interface DetailHeadView : UIView<PopoverViewDelegate,UIScrollViewDelegate>

@property(nonatomic,retain) PopoverView* optionPopV;

@property(nonatomic,assign) id<DetailHeaderDelegate> delegate;

@property(nonatomic,assign) int currentPage;
@property(nonatomic,assign) int totalPage;
@property(nonatomic,retain) UILabel* imgNumLab;

@property(nonatomic,assign) int pId;
@property(nonatomic,assign) int userId;
@property(nonatomic,assign) DynamicType type;
@property(nonatomic,retain) NSDictionary* dataDic;
@property(nonatomic,copy) NSString* textStr;

@property(nonatomic,retain) UIView* cardView;
@property(nonatomic,retain) UIView* buttomView;
@property(nonatomic,retain) UIButton* optionBtn;
@property(nonatomic,retain) UIButton* commentBtn;
@property(nonatomic,retain) UIButton* detailBtn;
@property(nonatomic,retain) UIView* headView;
@property(nonatomic,retain) UIImageView* headImageV;
@property(nonatomic,retain) UILabel* userNameLab;
@property(nonatomic,retain) UILabel* timeLab;
@property(nonatomic,retain) UILabel* stateLab;
@property(nonatomic,retain) UILabel* cardTypeLab;
@property(nonatomic,retain) UIView* midView;

-(void) writeDataInCell:(NSDictionary *)dic;

//更新部分内容
-(void) updateDataWith:(NSDictionary*) dic;

@end
