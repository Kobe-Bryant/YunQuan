//
//  ContactViewCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ContactViewCell.h"
#import "Global.h"

@implementation ContactViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImage *icon = [UIImage imageNamed:@"btn_chat_normal.png"];
        UIImage *highlightedIcon = [UIImage imageNamed:@"btn_chat_set.png"];
        UIImageView *iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(15,(55 - icon.size.height)/2 , icon.size.width, icon.size.height)];
        iconImg.image = icon;
        iconImg.highlightedImage = highlightedIcon;
        self.selectImage = iconImg;
        [self addSubview:iconImg];
        RELEASE_SAFE(iconImg);
        
        //头像
        UIImage *image = [UIImage imageNamed:@"ico_me.png"];
        UIImageView *listNameImg = [[UIImageView alloc]initWithImage:image];
        listNameImg.frame = CGRectMake(CGRectGetMaxX(self.selectImage.frame) + 10, (55.0 - 42)/2 , 42.f, 42.f);
        listNameImg.layer.cornerRadius = 3.0;
        listNameImg.layer.masksToBounds = YES;
        self.listNameImage = listNameImg;
        [self addSubview:listNameImg];
        RELEASE_SAFE(listNameImg);
        
        //名字
        UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.listNameImage.frame.size.width + self.listNameImage.frame.origin.x + 9, 2.0, 150.f, 30.f)];
        nameLab.backgroundColor = [UIColor clearColor];
        nameLab.textColor = RGBACOLOR(52, 52, 52, 1);
        nameLab.font = [UIFont boldSystemFontOfSize:16.0];
        self.nameLable = nameLab;
        [self addSubview:nameLab];
        RELEASE_SAFE(nameLab);
        
        //职位名字
        UILabel *positionLab = [[UILabel alloc]initWithFrame:CGRectMake(115.f, 2.0, 250.f, 30.f)];
        positionLab.backgroundColor = [UIColor clearColor];
        positionLab.textColor = RGBACOLOR(136, 136, 136, 1);
        positionLab.font = [UIFont systemFontOfSize:12.0];
        self.positionLable = positionLab;
        [self addSubview:positionLab];
        RELEASE_SAFE(positionLab);
        
        //公司名字
        UILabel *companyLab = [[UILabel alloc]initWithFrame:CGRectMake(self.listNameImage.frame.size.width + self.listNameImage.frame.origin.x + 9, 22.0, 250.f, 30.f)];
        companyLab.backgroundColor = [UIColor clearColor];
        companyLab.textColor = RGBACOLOR(136, 136, 136, 1);
        companyLab.font = [UIFont systemFontOfSize:12.0];
        self.companyLable = companyLab;
        [self addSubview:companyLab];
        RELEASE_SAFE(companyLab);
        
    }
    return self;
}

- (void)dealloc
{
    self.selectImage = nil;
    self.companyLable = nil;
    self.positionLable = nil;
    self.nameLable = nil;
    self.listNameImage = nil;
    [super dealloc];
}


@end
