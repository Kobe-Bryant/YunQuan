//
//  AssignCircleCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "AssignCircleCell.h"
#import "Global.h"

@implementation AssignCircleCell
@synthesize nameLable;
@synthesize lineImage;
@synthesize iconImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView* v = [[UIView alloc] initWithFrame:CGRectZero];
        self.selectedBackgroundView = v;
        [v release];
        
        UIImage *icon = [UIImage imageNamed:@"btn_chat_normal.png"];
        UIImage *highlightedIcon = [UIImage imageNamed:@"btn_chat_set.png"];
        self.iconImage = [[[UIImageView alloc]initWithFrame:CGRectMake(15,(55 - icon.size.height)/2 , icon.size.width, icon.size.height)] autorelease];
        self.iconImage.image = icon;
        self.iconImage.highlightedImage = highlightedIcon;
        [self addSubview:self.iconImage];
        
        //部门名称
        self.nameLable = [[[UILabel alloc]initWithFrame:CGRectMake(50, 12.0, 250.f, 30.f)] autorelease];
        self.nameLable.backgroundColor = [UIColor clearColor];
        self.nameLable.font = [UIFont systemFontOfSize:16.0];
        self.nameLable.textColor = RGBACOLOR(52, 52, 52, 1);
        [self addSubview:self.nameLable];
        
        //人员个数
        UILabel *countLab = [[UILabel alloc]initWithFrame:CGRectMake(280, (55 - 20)/2, 50.f, 20.f)];
        countLab.backgroundColor = [UIColor clearColor];
        countLab.font = [UIFont systemFontOfSize:16.0];
        countLab.textColor = RGBACOLOR(110, 110, 110, 1);
        self.countLable = countLab;
        [self addSubview:countLab];
        RELEASE_SAFE(countLab);
        
        //直线
        UIImage *lineImg = [UIImage imageNamed:@"img_group_underline.png"];
        self.lineImage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 54.5, 320, 0.5)] autorelease];
        self.lineImage.image = lineImg;
        [self addSubview:self.lineImage];
    }
    return self;
}

- (void)dealloc
{
    self.nameLable = nil;
    self.lineImage = nil;
    self.iconImage = nil;
    self.countLable = nil;
    [super dealloc];
}
@end
