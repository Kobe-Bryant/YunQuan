//
//  SecondCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SecondCell.h"
#import "Global.h"

@implementation SecondCell
@synthesize dredgeBtn;
@synthesize tip;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //头像
        UIImage *image1 = [UIImage imageNamed:@"img_landing_default220.png"];
        UIImageView *headImg = [[UIImageView alloc]initWithImage:image1];
        headImg.frame = CGRectMake(12, 10, 44, 44);
        headImg.layer.cornerRadius = 2.0;
        headImg.layer.masksToBounds = YES;
        self.headImage = headImg;
        [self addSubview:headImg];
        RELEASE_SAFE(headImg);
        
        //公司名称
        UILabel *companyLab = [[UILabel alloc]initWithFrame:CGRectMake(self.headImage.frame.origin.x + self.headImage.frame.size.width + 10, 11, 160, 20)];
        companyLab.backgroundColor = [UIColor clearColor];
        companyLab.font = [UIFont systemFontOfSize:15.0];
        companyLab.textColor = RGBACOLOR(51, 51, 51, 1);
        self.companyLable = companyLab;
        [self addSubview:companyLab];
        RELEASE_SAFE(companyLab);
        
        //浏览量
        UILabel *countLab = [[UILabel alloc]initWithFrame:CGRectMake(self.headImage.frame.origin.x + self.headImage.frame.size.width + 10, 33, 160, 20)];
        countLab.backgroundColor = [UIColor clearColor];
        countLab.font = [UIFont systemFontOfSize:12.0];
        countLab.textColor = RGBACOLOR(102, 102, 102, 1);
        self.countLable = countLab;
        [self addSubview:countLab];
        RELEASE_SAFE(countLab);
        
        //箭头
        UIImage *image2 = [UIImage imageNamed:@"ico_group_arrow1.png"];
        UIImageView *arrawImg = [[UIImageView alloc]initWithImage:image2];
        arrawImg.frame = CGRectMake(290, (64 - image2.size.height)/2, image2.size.width, image2.size.height);
        self.arrawImage = arrawImg;
        [self addSubview:arrawImg];
        RELEASE_SAFE(arrawImg);
        
        UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 20.f, 80.f, 30.f)];
        tipLabel.text = @"未开通";
        tipLabel.font = KQLSystemFont(16);
        tipLabel.textColor = [UIColor grayColor];
        tipLabel.backgroundColor = [UIColor clearColor];
        self.tip = tipLabel;
        [self.contentView addSubview:tipLabel];
        [tipLabel release];
        
        dredgeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dredgeBtn.titleLabel.font = KQLSystemFont(16);
        [dredgeBtn setTitle:@"申请开通" forState:UIControlStateNormal];
        [dredgeBtn setTitleColor:[UIColor colorWithRed:0/255.0f green:160/255.0 blue:233/255.0 alpha:1.f] forState:UIControlStateNormal];
        [dredgeBtn setFrame:CGRectMake(CGRectGetMaxY(self.tip.frame) + 20.f, 20.f, 100.f, 30.f)];
        [self.contentView addSubview:dredgeBtn];
        }
    return self;
}

//开通liveApp

-(void)openCompanyLightApp{
    self.headImage.hidden = NO;
    self.companyLable.hidden = NO;
    self.countLable.hidden = NO;
    self.arrawImage.hidden = NO;
    
    self.tip.hidden = YES;
    self.dredgeBtn.hidden = YES;
}

//未开通公司轻APP
- (void)noDredgeCompanyLightApp{
    self.headImage.hidden = YES;
    self.companyLable.hidden = YES;
    self.countLable.hidden = YES;
    self.arrawImage.hidden = YES;
    
    self.tip.hidden = NO;
    self.dredgeBtn.hidden = NO;
}

- (void)dealloc
{
    self.headImage = nil;
    self.companyLable = nil;
    self.countLable = nil;
    self.arrawImage = nil;
    [super dealloc];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
