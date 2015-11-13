//
//  CicleLayerCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-13.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "CicleLayerCell.h"
#import "Global.h"

@implementation CicleLayerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        //人员个数
        UILabel *countLab = [[UILabel alloc]initWithFrame:CGRectMake(280, 11.0, 50.f, 20.f)];
        countLab.backgroundColor = [UIColor clearColor];
        countLab.font = [UIFont systemFontOfSize:16.0];
        countLab.textColor = RGBACOLOR(110, 110, 110, 1);
        self.countLable = countLab;
        [self addSubview:countLab];
        RELEASE_SAFE(countLab);
        
        //部门名称
        UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(75, 11.0, 250.f, 30.f)];
        nameLab.backgroundColor = [UIColor clearColor];
        nameLab.font = [UIFont systemFontOfSize:16.0];
        nameLab.textColor = RGBACOLOR(52, 52, 52, 1);
        self.nameLable = nameLab;
        [self addSubview:nameLab];
        RELEASE_SAFE(nameLab);
        
        //箭头
        UIImage *arrow = [UIImage imageNamed:@"ico_group_arrow1.png"];
        UIImageView *arrowImg = [[UIImageView alloc]initWithFrame:CGRectMake(285,(53 - arrow.size.height)/2 , arrow.size.width, arrow.size.height)];
        arrowImg.image = arrow;
        arrowImg.hidden = YES;
        self.arrowImage = arrowImg;
        [self addSubview:arrowImg];
        RELEASE_SAFE(arrowImg);
        
        //箭头
        UIImage *arrowSimple = [UIImage imageNamed:@"ico_group_down.png"];
        UIImageView *arrowSimpleImg = [[UIImageView alloc]initWithFrame:CGRectMake(280,(53 - arrow.size.height)/2 , arrow.size.width, arrow.size.height)];
        arrowSimpleImg.image = arrowSimple;
        arrowSimpleImg.hidden = YES;
        self.arrowSimpleImage = arrowSimpleImg;
        [self addSubview:arrowSimpleImg];
        RELEASE_SAFE(arrowSimpleImg);
        
        //直线
        UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
        UIImageView *lineImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60, 320, 0.5)];
        lineImg.image = line;
        self.lineImage = lineImg;
        [self addSubview:lineImg];
        RELEASE_SAFE(lineImg);
    }
    return self;
}

- (void)dealloc
{
    self.arrowSimpleImage = nil;
    self.arrowImage = nil;
    self.nameLable = nil;
    self.lineImage = nil;
    self.countLable = nil;
    [super dealloc];
}



@end
