//
//  RelateCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "RelateCell.h"
#import "Global.h"

@implementation RelateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initWithCell];
    }
    return self;
}

- (void)initWithCell{
    // 头像
    UIImage *image = [UIImage imageNamed:@"img_landing_default220.png"];
    UIImageView *iconImg = [[UIImageView alloc]initWithImage:image];
    iconImg.layer.cornerRadius = 3.0;
    iconImg.layer.masksToBounds = YES;
    iconImg.frame = CGRectMake(10, 5, 45, 45);
    self.iconImage = iconImg;
    [self addSubview:iconImg];
    RELEASE_SAFE(iconImg);
    
    //姓名
    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImage.frame) + 5, CGRectGetMinY(self.iconImage.frame) + 3, 90, 20)];
    nameLab.backgroundColor = [UIColor clearColor];
    nameLab.font = [UIFont boldSystemFontOfSize:16.0];
    self.nameLable = nameLab;
    [self addSubview:nameLab];
    RELEASE_SAFE(nameLab);
    
    //点赞
    _loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loveBtn.hidden = YES;
    _loveBtn.frame = CGRectMake(CGRectGetMaxX(self.iconImage.frame), CGRectGetMinY(self.nameLable.frame) + 20, 110, 18);
    _loveBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_loveBtn setTitleColor:RGBACOLOR(51, 51, 51, 1) forState:UIControlStateNormal];
    _loveBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:_loveBtn];
    
    //评论
    TQRichTextView *commentLab = [[TQRichTextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImage.frame) + 5, CGRectGetMinY(self.nameLable.frame) + 20, 180, 20)];
    commentLab.backgroundColor = [UIColor clearColor];
    commentLab.textColor = RGBACOLOR(51, 51, 51, 1);
    commentLab.userInteractionEnabled = NO;
    commentLab.lineSpacing = 1.2;
    commentLab.font = [UIFont systemFontOfSize:13.0];
    self.commentLable = commentLab;
    [self addSubview:commentLab];
    RELEASE_SAFE(commentLab);
    
    //时间
    UILabel *timeLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImage.frame) + 5, CGRectGetMaxY(self.commentLable.frame) - 1, 180, 20)];
    timeLab.backgroundColor = [UIColor clearColor];
    timeLab.textColor = RGBACOLOR(136, 136, 136, 1);
    timeLab.font = [UIFont systemFontOfSize:10.0];
    self.timeLable = timeLab;
    [self addSubview:timeLab];
    RELEASE_SAFE(timeLab);
    
    //后面内容图片
    UIImage *image2 = [UIImage imageNamed:@"img_landing_default220.png"];
    UIImageView *contentImg = [[UIImageView alloc]initWithImage:image2];
    contentImg.frame = CGRectMake(ScreenWidth - 60 -10, 8, 55, 55);
    self.contentImage = contentImg;
    [self addSubview:contentImg];
    RELEASE_SAFE(contentImg);
    
    //后面内容文字
    UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth - 60 -10, 8, 55, 55)];
    contentLab.font = [UIFont systemFontOfSize:11.0];
    contentLab.backgroundColor = [UIColor clearColor];
    contentLab.numberOfLines = 0;
    contentLab.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLable = contentLab;
    [self addSubview:contentLab];
    RELEASE_SAFE(contentLab);
}

- (void)dealloc
{
    self.iconImage = nil;
    self.nameLable = nil;
    self.commentLable = nil;
    self.timeLable = nil;
    self.contentImage = nil;
    self.contentLable = nil;
    [super dealloc];
}

@end
