//
//  EditHeaderView.m
//  LinkeBe
//
//  Created by Dream on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "EditHeaderView.h"
#import "Global.h"

@implementation EditHeaderView
@synthesize iconImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15, (80 - 20)/2, 70,20)];
        titleLable.text = @"头像";
        titleLable.textColor = RGBACOLOR(136, 136, 136, 1);
        titleLable.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:titleLable];
        [titleLable release];
        
        //照片
        UIImage *image = [UIImage imageNamed:@"img_landing_default220.png"];
        UIImageView *iconImg = [[UIImageView alloc]initWithImage:image];
        iconImg.frame = CGRectMake(70, (80 - 50)/2, 50, 50);
        self.iconImage = iconImg;
        [self addSubview:iconImg];
        RELEASE_SAFE(iconImg);
        
        UILabel *clickLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iconImage.frame) + 70, (80 - 20)/2, 100,20)];
        clickLable.text = @"点击更换真实头像";
        clickLable.textColor = RGBACOLOR(204, 204, 204, 1);
        clickLable.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:clickLable];
        [clickLable release];
        
        //箭头
        UIImage *image2 = [UIImage imageNamed:@"ico_group_arrow1.png"];
        UIImageView *arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(290,(80 - image2.size.height)/2 , image2.size.width, image2.size.height)];
        arrowImage.image = image2;
        [self addSubview:arrowImage];
        [arrowImage release];
        
        //直线
        if (IOS6_OR_LATER) {
            UIImage *line = [UIImage imageNamed:@"img_group_underline.png"];
            UIImageView *lineImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 79.5, 320, 0.5)];
            lineImg.image = line;
            [self addSubview:lineImg];
            RELEASE_SAFE(lineImg);
        }
    }
    return self;
}

- (void)dealloc {
    self.iconImage = nil;
    [super dealloc];
}


@end
