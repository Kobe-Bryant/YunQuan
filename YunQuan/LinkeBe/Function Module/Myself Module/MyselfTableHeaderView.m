//
//  MyselfTableHeaderView.m
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "MyselfTableHeaderView.h"
#import "Global.h"


@implementation MyselfTableHeaderView

@synthesize iconImageBtn = _iconImageBtn;
@synthesize editBtn = _editBtn;

- (void)dealloc{
    self.sexImage = nil;
    self.personNameLable = nil;
    self.dataImproveLable = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initWithPersionInfo];
    }
    return self;
}

- (void)initWithPersionInfo {
    //头像
//    UIImage *image1 = [UIImage imageNamed:@"ico_default_portrait_male.png"];
    _iconImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _iconImageBtn.layer.cornerRadius = 3.0;
    _iconImageBtn.layer.masksToBounds = YES;
//    [self.iconImageBtn setBackgroundImage:image1 forState:UIControlStateNormal];
    [_iconImageBtn setFrame:CGRectMake(12, 12, 50, 50)];
    [self addSubview:_iconImageBtn];
    
    //姓名
    UILabel *personNameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.iconImageBtn.frame.origin.x + self.iconImageBtn.frame.size.width + 8, 15, 80, 20)];
    personNameLab.backgroundColor = [UIColor clearColor];
    personNameLab.textAlignment = NSTextAlignmentLeft;
    personNameLab.font = [UIFont boldSystemFontOfSize:16.0];
    self.personNameLable = personNameLab;
    [self addSubview:personNameLab];
    RELEASE_SAFE(personNameLab);
    
    //性别
    UIImage *image2 = [UIImage imageNamed:@"ico_me_female.png"];
    UIImageView *sexImg = [[UIImageView alloc]initWithImage:image2];
    sexImg.frame = CGRectMake(60, 20, image2.size.width, image2.size.height);
    self.sexImage = sexImg;
    [self addSubview:sexImg];
    RELEASE_SAFE(sexImg);
    
    //资料完成度
    UILabel *dataImproveLab = [[UILabel alloc]initWithFrame:CGRectMake(self.iconImageBtn.frame.origin.x + self.iconImageBtn.frame.size.width + 8, 42, 180, 20)];
    dataImproveLab.backgroundColor = [UIColor clearColor];
    dataImproveLab.font = [UIFont systemFontOfSize:13.0];
    dataImproveLab.textColor = RGBACOLOR(136, 136, 136, 1);
    self.dataImproveLable = dataImproveLab;
    [self addSubview:dataImproveLab];
    RELEASE_SAFE(dataImproveLab);
    
    //职位
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editBtn setBackgroundImage:IMGREADFILE(LinkeBe_Myself_EditImge) forState:UIControlStateNormal];
    [_editBtn setFrame:CGRectMake(ScreenWidth-40, self.dataImproveLable.frame.origin.y-5 , IMGREADFILE(LinkeBe_Myself_EditImge).size.width, IMGREADFILE(LinkeBe_Myself_EditImge).size.height)];
    [self addSubview:_editBtn];
    
    //直线
    if (IOS6_OR_LATER) {
        UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
        UIImageView *lineImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 73.5, 320, 0.5)];
        lineImg.image = line;
        [self addSubview:lineImg];
        RELEASE_SAFE(lineImg);
    }
}


@end

