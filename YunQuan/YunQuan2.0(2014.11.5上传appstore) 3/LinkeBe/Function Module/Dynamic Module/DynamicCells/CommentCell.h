//
//  CommentCell.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TQRichTextView.h"

@protocol CommentCellDelegate <NSObject>

-(void) headAndNameTouchWithUserId:(NSDictionary*) dic;

@optional
-(void) nameButtonClick:(NSDictionary*) dic;

@end

@interface CommentCell : UITableViewCell

@property(nonatomic,assign) id<CommentCellDelegate> delegate;

@property(nonatomic,assign) int fromId;
@property(nonatomic,assign) int toId;
@property(nonatomic,assign) int commentId;
@property(nonatomic,retain) NSDictionary* dataDic;

@property(nonatomic,retain) UIImageView* headImageV;
@property(nonatomic,retain) UILabel* nameLab;
@property(nonatomic,retain) UILabel* timeLab;
@property(nonatomic,retain) TQRichTextView* textView;
@property(nonatomic,retain) UIImageView* lineImgV;

//填充数据
-(void) writeCommentDataInCell:(NSDictionary*) dic;

//获取高度
+(CGFloat) getCommentCellHeightWith:(NSDictionary*) dic;

@end
