//
//  CommentCell.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "CommentCell.h"

#import "UIImageView+WebCache.h"
#import "Common.h"
#import "DynamicCommon.h"

#define MARGIN  5.0
#define DEFAULTCELLH    45.0
#define IMAGEHEIGHT     30.0
#define TEXTWIDTH   270.0

#define HEHEIMAGETAG    1000

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //头像
        UIImageView* headV = [[UIImageView alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, IMAGEHEIGHT, IMAGEHEIGHT)];
        headV.userInteractionEnabled = YES;
        headV.backgroundColor = DynamicCardBackGround;
        self.headImageV = headV;
        [self.contentView addSubview:headV];
        [headV release];
        
        UITapGestureRecognizer* htap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTouch)];
        [self.headImageV addGestureRecognizer:htap];
        [htap release];
        
        //名字
        UILabel* nameL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.headImageV.frame) + MARGIN, MARGIN, 100, 15)];
        nameL.backgroundColor = [UIColor clearColor];
        nameL.textColor = BLUECOLOR;
        nameL.font = [UIFont systemFontOfSize:14];
        nameL.userInteractionEnabled = YES;
        self.nameLab = nameL;
        [self.contentView addSubview:nameL];
        [nameL release];
        
        UITapGestureRecognizer* ntap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTouch)];
        [self.nameLab addGestureRecognizer:ntap];
        [ntap release];
        
        //内容
        TQRichTextView* textV = [[TQRichTextView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.nameLab.frame), CGRectGetMaxY(self.nameLab.frame), TEXTWIDTH, 15)];
        textV.font = [UIFont systemFontOfSize:13];
        textV.textColor = DARKCOLOR;
        textV.backgroundColor = [UIColor clearColor];
        textV.userInteractionEnabled = NO;
        textV.lineSpacing = 1.2;
        self.textView = textV;
        [self.contentView addSubview:textV];
        [textV release];
        
        //时间
        UILabel* timeL = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 2*10 - 100, MARGIN, 100, 10)];
        timeL.textColor = DARKCOLOR;
        timeL.textAlignment = NSTextAlignmentRight;
        timeL.font = [UIFont systemFontOfSize:10];
        timeL.backgroundColor = [UIColor clearColor];
        self.timeLab = timeL;
        [self.contentView addSubview:timeL];
        [timeL release];
        
        //line
        UIImageView* limgV = [[UIImageView alloc] init];
        limgV.frame = CGRectMake(CGRectGetMaxX(self.headImageV.frame) + 5, 45 - 0.5, ScreenWidth - 4*MARGIN - IMAGEHEIGHT - 10, 0.5);
        limgV.image = IMGREADFILE(DynamicPic_detail_comment_line);
        self.lineImgV = limgV;
        [self.contentView addSubview:limgV];
        [limgV release];
        
        self.lineImgV.hidden = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) writeCommentDataInCell:(NSDictionary *)dic{
    for (UIView* v in self.contentView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            [v removeFromSuperview];
        }
        if ([v isKindOfClass:[UIImageView class]] && v.tag == HEHEIMAGETAG) {
            [v removeFromSuperview];
        }
    }
    
    self.fromId = [[dic objectForKey:@"fromId"] intValue];
    self.toId = [[dic objectForKey:@"toId"] intValue];
    self.dataDic = [dic copy];
    self.commentId = [[dic objectForKey:@"id"] intValue];
    
    [self.headImageV setImageWithURL:[dic objectForKey:@"fromPortrait"] placeholderImage:PLACEHOLDERIMAGE(_fromId)];
    self.nameLab.text = [dic objectForKey:@"fromName"];
    self.timeLab.text = [Common makeFriendTime:[[dic objectForKey:@"createdTime"] intValue]];
    
    //根据不同的type布局textView，0表示评论，1赞，2呵呵，3回复
    int type = [[dic objectForKey:@"type"] intValue];
    [self layoutTextViewWithType:type];
    
    self.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(self.textView.frame) + 10);
}

//根据不同类型布局textview
-(void) layoutTextViewWithType:(int) type{
    if (type == 1 || type == 2) {
        UIImageView* imgV = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.nameLab.frame), CGRectGetMaxY(self.nameLab.frame) + 3, 10, 10)];
        UIImage* image = nil;
        NSString* textStr = nil;
        if (type == 1) {
            image = IMGREADFILE(DynamicPic_detail_comment_top);
            textStr = @"   不错，赞一个";
        }else{
            image = IMGREADFILE(DynamicPic_detail_comment_hehe);
            textStr = @"   呵呵...";
        }
        imgV.tag = HEHEIMAGETAG;
        imgV.image = image;
        [self.contentView addSubview:imgV];
        [imgV release];
        
        self.textView.text = textStr;
        
    }else if (type == 3) {
        //回复  创建名字button盖住
        NSString* toName = [_dataDic objectForKey:@"toName"];
        NSString* content = [NSString stringWithFormat:@"回复  %@  : %@",toName,[_dataDic objectForKey:@"content"]];
        
        [self.contentView addSubview:[self addNameBtnOnTextWith:toName frame:self.textView.frame]];
        self.textView.text = content;
        
        CGFloat textH = [TQRichTextView getRechTextViewHeightWithText:content viewWidth:TEXTWIDTH font:[UIFont systemFontOfSize:13] lineSpacing:1.2];
        self.textView.frame = CGRectMake(CGRectGetMinX(self.nameLab.frame), CGRectGetMaxY(self.nameLab.frame), TEXTWIDTH, textH + 10);
        self.lineImgV.frame = CGRectMake(CGRectGetMaxX(self.headImageV.frame) + 5, CGRectGetMaxY(self.textView.frame) - 0.5, ScreenWidth - 4*MARGIN - IMAGEHEIGHT - 10, 0.5);
        
    }else{
        self.textView.text = [_dataDic objectForKey:@"content"];
        
        CGFloat textH = [TQRichTextView getRechTextViewHeightWithText:[_dataDic objectForKey:@"content"] viewWidth:TEXTWIDTH font:[UIFont systemFontOfSize:13] lineSpacing:1.2];
        self.textView.frame = CGRectMake(CGRectGetMinX(self.nameLab.frame), CGRectGetMaxY(self.nameLab.frame), TEXTWIDTH, textH + 10);
        self.lineImgV.frame = CGRectMake(CGRectGetMaxX(self.headImageV.frame) + 5, CGRectGetMaxY(self.textView.frame) - 0.5, ScreenWidth - 4*MARGIN - IMAGEHEIGHT - 10, 0.5);
    }
}

//创建名字button
-(UIButton*) addNameBtnOnTextWith:(NSString*) name frame:(CGRect) frame{
    UIButton* nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nameBtn setTitle:name forState:UIControlStateNormal];
    [nameBtn setTitleColor:BLUECOLOR forState:UIControlStateNormal];
    [nameBtn addTarget:self action:@selector(nameBtnClick) forControlEvents:UIControlEventTouchUpInside];
    nameBtn.titleLabel.font = KQLboldSystemFont(13);
    
    CGSize size = [name sizeWithFont:KQLboldSystemFont(13) constrainedToSize:CGSizeMake(100, 60) lineBreakMode:NSLineBreakByWordWrapping];
    nameBtn.frame = CGRectMake(25 + frame.origin.x, frame.origin.y, size.width + 10, 16);
    nameBtn.backgroundColor = [UIColor whiteColor];
    
    return nameBtn;
}

#pragma mark - userheader
-(void) headTouch{
    if (_delegate && [_delegate respondsToSelector:@selector(headAndNameTouchWithUserId:)]) {
        [_delegate headAndNameTouchWithUserId:_dataDic];
    }
}

#pragma mark - nameBtn
-(void) nameBtnClick{
    if (_delegate && [_delegate respondsToSelector:@selector(nameButtonClick:)]) {
        [_delegate nameButtonClick:_dataDic];
    }
}

+(CGFloat) getCommentCellHeightWith:(NSDictionary *)dic{
    CGFloat height = 0;
    
    int type = [[dic objectForKey:@"type"] intValue];
    if (type == 1 || type == 2) {
        height = 45.0;
    }else{
        CGFloat textH = [TQRichTextView getRechTextViewHeightWithText:[dic objectForKey:@"content"] viewWidth:TEXTWIDTH font:[UIFont systemFontOfSize:13] lineSpacing:1.2];
        height = textH + 10;
        height += 20;
    }
    
    return height>45.0?height:45.0;
}

-(void) dealloc{
    [_headImageV release];
    [_nameLab release];
    [_timeLab release];
    [_textView release];
    
    [super dealloc];
}

@end
