//
//  CicleListCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-13.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "CicleListCell.h"
#import "Global.h"

@implementation CicleListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //头像
        UIImage *image = [UIImage imageNamed:@"ico_me.png"];
        UIImageView *listNameImg = [[UIImageView alloc]initWithImage:image];
        listNameImg.frame = CGRectMake(10.f, 5.f, 42.f, 42.f);
        listNameImg.layer.cornerRadius = 3.0;
        listNameImg.layer.masksToBounds = YES;
        self.listNameImage = listNameImg;
        [self addSubview:listNameImg];
        RELEASE_SAFE(listNameImg);
        
        //名字
        UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.listNameImage.frame.size.width + self.listNameImage.frame.origin.x + 9, 2.0, 120.f, 30.f)];
        nameLab.backgroundColor = [UIColor clearColor];
        nameLab.textColor = RGBACOLOR(52, 52, 52, 1);
        nameLab.font = [UIFont boldSystemFontOfSize:16.0];
        self.nameLable = nameLab;
        [self addSubview:nameLab];
        RELEASE_SAFE(nameLab);
        
        //职位名字
        UILabel *positionLab = [[UILabel alloc]initWithFrame:CGRectMake(115.f, 2.0, 250.f, 30.f)];
        positionLab.backgroundColor = [UIColor clearColor];
        positionLab.textColor = RGBACOLOR(70, 70, 70, 1);
        positionLab.font = [UIFont systemFontOfSize:12.0];
        self.positionLable = positionLab;
        [self addSubview:positionLab];
        RELEASE_SAFE(positionLab);
        
        //公司名字
        UILabel *companyLab = [[UILabel alloc]initWithFrame:CGRectMake(self.listNameImage.frame.size.width + self.listNameImage.frame.origin.x + 9, 22.0, 190, 30.f)];
        companyLab.backgroundColor = [UIColor clearColor];
        companyLab.textColor = RGBACOLOR(110, 110, 110, 1);
        companyLab.font = [UIFont systemFontOfSize:12.0];
        self.companyLable = companyLab;
        [self addSubview:companyLab];
        RELEASE_SAFE(companyLab);
        
        //发送聊天按钮
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.hidden = YES;
        _sendBtn.frame = CGRectMake(250, 13, 50, 28);
        _sendBtn.layer.borderWidth = 0.5f;
        _sendBtn.layer.borderColor = RGBACOLOR(48, 122, 208, 1).CGColor;
        _sendBtn.layer.cornerRadius = 3.0;
        _sendBtn.backgroundColor = RGBACOLOR(250, 250, 250, 1);
        [_sendBtn setTitleColor:RGBACOLOR(48, 122, 208, 1) forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [self addSubview:_sendBtn];
        
        //已邀请lable
        UILabel *inviteLab = [[UILabel alloc]initWithFrame:CGRectMake(255.f, 13.0, 60.f, 28.f)];
        inviteLab.hidden = YES;
        inviteLab.backgroundColor = [UIColor clearColor];
        inviteLab.text = @"已邀请";
        inviteLab.textColor = RGBACOLOR(110, 110, 110, 1);
        inviteLab.font = [UIFont systemFontOfSize:12.0];
        self.inviteLable = inviteLab;
        [self addSubview:inviteLab];
        RELEASE_SAFE(inviteLab);
    }
    return self;
}

- (void)dealloc
{
    self.listNameImage = nil;
    self.companyLable = nil;
    self.nameLable = nil;
    self.inviteLable = nil;
    self.positionLable = nil;
    [super dealloc];
}

@end
