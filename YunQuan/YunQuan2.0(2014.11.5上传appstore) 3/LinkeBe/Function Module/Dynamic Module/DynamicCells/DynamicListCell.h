//
//  DynamicListCell.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DynamicCommon.h"

#import "PopoverView.h"

#import "DynamicListManager.h"

#import "TSPopoverController.h"

@protocol DynamicListCellDelegate <NSObject>

//评论点击
-(void) commentClickCallBackWith:(NSIndexPath*) iPath;

//交互选项点击
-(void) optionClickCallBackWith:(NSIndexPath*) iPath type:(int) btype;

//详情点击
-(void) detailClickCallBackWith:(NSIndexPath*) iPath;

//头像点击
-(void) headClickCallBackWith:(NSIndexPath*) iPath;

@optional
//类型点击
-(void) itemClickCallBackWith:(DynamicType) dyType;

//参与／我有我要点击
-(void) roundButtonClickCallBackWithType:(DynamicType) dyType indexPath:(NSIndexPath*) iPath sender:(UIButton*) sender;

//移除其他弹出框
-(void) removeOptionBoxWith:(NSIndexPath*) iPath;

@end

@interface DynamicListCell : UITableViewCell<PopoverViewDelegate,DynamicListManagerDelegate>{
    int selectButtonIndex;
}

@property(nonatomic,retain) PopoverView* optionPopV;

@property(nonatomic,assign) id<DynamicListCellDelegate> delegate;

@property(nonatomic,assign) int pId;
@property(nonatomic,assign) int userId;
@property(nonatomic,assign) DynamicType type;
@property(nonatomic,retain) NSDictionary* dataDic;
@property(nonatomic,copy) NSString* textStr;

@property(nonatomic,copy) NSIndexPath* indexPath;

@property(nonatomic,retain) UIView* cardView;
@property(nonatomic,retain) UIView* buttomView;
@property(nonatomic,retain) UIButton* optionBtn;
@property(nonatomic,retain) UIButton* detailBtn;
@property(nonatomic,retain) UIButton* commentBtn;
@property(nonatomic,retain) UIView* headView;
@property(nonatomic,retain) UIImageView* headImageV;
@property(nonatomic,retain) UILabel* userNameLab;
@property(nonatomic,retain) UILabel* timeLab;
@property(nonatomic,retain) UILabel* stateLab;
@property(nonatomic,retain) UILabel* cardTypeLab;
@property(nonatomic,retain) UIView* midView;

//填充数据
-(void) writeDataInCell:(NSDictionary*) dic;

//获取cell高度
+(CGFloat) getDynamicListCellHeightWith:(NSDictionary*) dic;

//收起交互选项
-(void) hideOptionBox;

//显示交互选项
-(void) showOptionBox;

@end
