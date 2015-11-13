//
//  PersionInfoView.m
//  LinkeBe
//
//  Created by Dream on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PersionInfoView.h"
#import "Global.h"

@implementation PersionInfoView

- (void)dealloc{
    self.iconImage = nil;
    self.sexImage = nil;
    self.personNameLable = nil;
    self.companyNameLable = nil;
    self.positionLable = nil;
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
    UIImage *image1 = [UIImage imageNamed:@"img_landing_default220.png"];
    UIImageView *iconImg = [[UIImageView alloc]initWithImage:image1];
    iconImg.userInteractionEnabled = YES;
    iconImg.layer.cornerRadius = 3.0;
    iconImg.layer.masksToBounds = YES;
    iconImg.frame = CGRectMake(12, (80 - 50)/2, 50, 50);
    self.iconImage = iconImg;
    [self addSubview:iconImg];
    RELEASE_SAFE(iconImg);
    
    //姓名
    UILabel *personNameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.iconImage.frame.origin.x + self.iconImage.frame.size.width + 8, CGRectGetMinY(self.iconImage.frame) + 3, 120, 20)];
    personNameLab.backgroundColor = [UIColor clearColor];
    personNameLab.font = [UIFont boldSystemFontOfSize:17.0];
    self.personNameLable = personNameLab;
    [self addSubview:personNameLab];
    RELEASE_SAFE(personNameLab);
    
    //性别
    UIImage *image2 = [UIImage imageNamed:@"ico_me_female.png"];
    UIImageView *sexImg = [[UIImageView alloc]initWithImage:image2];
    sexImg.frame = CGRectMake(60,CGRectGetMaxY(self.personNameLable.frame) - image2.size.height , image2.size.width, image2.size.height);
    self.sexImage = sexImg;
    [self addSubview:sexImg];
    RELEASE_SAFE(sexImg);
    
    //公司名称
    UILabel *companyNameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.iconImage.frame.origin.x + self.iconImage.frame.size.width + 8, CGRectGetMaxY(self.personNameLable.frame)+ 8, 250, 20)];
    companyNameLab.backgroundColor = [UIColor clearColor];
    companyNameLab.font = [UIFont systemFontOfSize:13.0];
    companyNameLab.textColor = RGBACOLOR(136, 136, 136, 1);
    self.companyNameLable = companyNameLab;
    [self addSubview:companyNameLab];
    RELEASE_SAFE(companyNameLab);
    
    //职位
    UILabel *positionLab = [[UILabel alloc]initWithFrame:CGRectMake(260, CGRectGetMaxY(self.personNameLable.frame)+ 7, 80.0, 20)];
    positionLab.backgroundColor = [UIColor clearColor];
    positionLab.font = [UIFont systemFontOfSize:12.0];
    positionLab.textColor = RGBACOLOR(136, 136, 136, 1);
    self.positionLable = positionLab;
    [self addSubview:positionLab];
    RELEASE_SAFE(positionLab);
    //直线
    if (IOS6_OR_LATER) {
        UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
        UIImageView *lineImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 79.5, 320, 0.5)];
        lineImg.image = line;
        [self addSubview:lineImg];
        RELEASE_SAFE(lineImg);
    }
}


@end
