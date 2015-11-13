//
//  CicleListHeaderView.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "CicleListHeaderView.h"
#import "Global.h"

@implementation CicleListHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initWithHeaderView];
    }
    return self;
}

- (void)initWithHeaderView {
    UIImage *image = [UIImage imageNamed:@"group_logo1.png"];
    UIImageView *iconImg = [[UIImageView alloc]initWithImage:image];
    iconImg.frame = CGRectMake(20, (60 - image.size.height)/2, image.size.width, image.size.height);
    self.iconImage = iconImg;
    [self addSubview:iconImg];
    RELEASE_SAFE(iconImg);
    
    UILabel *nameLab = [[UILabel alloc]initWithFrame:CGRectMake(self.iconImage.frame.origin.x + self.iconImage.frame.size.width + 15, (60 -30)/2, 200, 30)];
    nameLab.font = [UIFont systemFontOfSize:16.0];
    nameLab.textColor = RGBACOLOR(52, 52, 52, 1);
    self.nameLable = nameLab;
    [self addSubview:nameLab];
    RELEASE_SAFE(nameLab);
}

- (void)dealloc
{
    self.iconImage = nil;
    self.nameLable = nil;
    [super dealloc];
}

@end
