//
//  PermissionCell.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PermissionCell.h"

#import "DynamicCommon.h"

@implementation PermissionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setUp{
    //头像
    UIImageView* headImgV = [[UIImageView alloc] init];
    headImgV.frame = CGRectMake(5, 5, 45, 45);
    headImgV.layer.cornerRadius = 5.0;
    headImgV.clipsToBounds = YES;
    headImgV.userInteractionEnabled = YES;
    headImgV.backgroundColor = DynamicCardBackGround;
    self.headImageView = headImgV;
    [self.contentView addSubview:headImgV];
    [headImgV release];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTouch)];
    [self.headImageView addGestureRecognizer:tap];
    [tap release];
    
    //名字
    UILabel* nLab = [[UILabel alloc] init];
    nLab.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 10, 5, 100, 20);
    nLab.textColor = DynamicCardNameColor;
    nLab.textAlignment = NSTextAlignmentLeft;
    nLab.font = KQLboldSystemFont(15);
    nLab.backgroundColor = [UIColor clearColor];
    self.nameLab = nLab;
    [self.contentView addSubview:nLab];
    [nLab release];
    
    //职位
    UILabel* pLab = [[UILabel alloc] init];
    pLab.frame = CGRectMake(0, CGRectGetMaxY(self.nameLab.frame) - 15, 100, 15);
    pLab.textColor = DynamicCardTextColor;
    pLab.textAlignment = NSTextAlignmentLeft;
    pLab.font = KQLboldSystemFont(12);
    pLab.backgroundColor = [UIColor clearColor];
    self.positionLab = pLab;
    [self.contentView addSubview:pLab];
    [pLab release];
    
    //公司
    UILabel* cLab = [[UILabel alloc] init];
    cLab.frame = CGRectMake(CGRectGetMinX(self.nameLab.frame), CGRectGetMaxY(self.nameLab.frame) + 5, 200, 15);
    cLab.textColor = DynamicCardTextColor;
    cLab.textAlignment = NSTextAlignmentLeft;
    cLab.font = KQLboldSystemFont(12);
    cLab.backgroundColor = [UIColor clearColor];
    self.companylab = cLab;
    [self.contentView addSubview:cLab];
    [cLab release];
    
    //聊聊按钮
    UIButton* chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    chatBtn.frame = CGRectMake(self.bounds.size.width - 20 - 50, 15, 50, 25);
    [chatBtn setTitle:@"聊聊" forState:UIControlStateNormal];
    [chatBtn setTitleColor:DynamicPermissionChatButtonTextColor forState:UIControlStateNormal];
    [chatBtn addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
    chatBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    chatBtn.layer.borderWidth = 0.5f;
    chatBtn.layer.borderColor = RGBACOLOR(48, 122, 208, 1).CGColor;
    chatBtn.layer.cornerRadius = 3.0;
    chatBtn.backgroundColor = RGBACOLOR(250, 250, 250, 1);
    
    [self.contentView addSubview:chatBtn];
}

-(void) writePermissionDataInCell:(NSDictionary *)dic{
    self.dataDic = dic;
    self.userId = [[dic objectForKey:@"userId"] intValue];
    self.orgUserId = [[dic objectForKey:@"orgUserId"] intValue];
    
    //赋值并调整name和position的位置
    [self.headImageView setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"portrait"]] placeholderImage:PLACEHOLDERIMAGE(_userId)];
    self.nameLab.text = [dic objectForKey:@"realname"];
    CGSize nameSize = [[dic objectForKey:@"realname"] sizeWithFont:self.nameLab.font constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.positionLab.frame = CGRectMake(CGRectGetMinX(self.nameLab.frame) + nameSize.width + 15, CGRectGetMaxY(self.nameLab.frame) - 15, 100, 15);
    self.positionLab.text = [dic objectForKey:@"companyRole"];
    self.companylab.text = [dic objectForKey:@"companyName"];
}

#pragma mark - chat
-(void) chatClick{
    if (_delegate && [_delegate respondsToSelector:@selector(chatClickWithUserInfo:)]) {
        [_delegate chatClickWithUserInfo:_dataDic];
    }
}

-(void) headTouch{
    if (_delegate && [_delegate respondsToSelector:@selector(headClickWithUserId:)]) {
        [_delegate headClickWithUserId:_dataDic];
    }
}

-(void) dealloc{
    [_headImageView release];
    [_nameLab release];
    [_positionLab release];
    [_companylab release];
    
    [super dealloc];
}

@end
