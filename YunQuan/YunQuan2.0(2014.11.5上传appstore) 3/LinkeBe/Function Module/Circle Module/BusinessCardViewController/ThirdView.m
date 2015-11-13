//
//  ThirdView.m
//  LinkeBe
//
//  Created by Dream on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ThirdView.h"
#import "Global.h"

@implementation ThirdView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSubCollectionCellView];
    }
    return self;
}

-(void) initSubCollectionCellView
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    UIImageView *iconImg = [[UIImageView alloc] init];
    iconImg.layer.cornerRadius = 3.0;
    iconImg.layer.masksToBounds = YES;
    iconImg.image = [UIImage imageNamed:@"ico_default_portrait_male.png"];
    [iconImg setFrame:CGRectMake(13, 13, 38, 38)];
    iconImg.userInteractionEnabled = YES;
    self.iconImageView = iconImg;
    [self addSubview:iconImg];
    RELEASE_SAFE(iconImg);
    
    //名称
    UILabel *titleNameLab = [[UILabel alloc ]initWithFrame:
                      CGRectMake(self.iconImageView.frame.size.width+self.iconImageView.frame.origin.x+8, self.iconImageView.frame.origin.y, 160, 18)];
    titleNameLab.textAlignment = NSTextAlignmentLeft;
    titleNameLab.textColor = RGBACOLOR(51, 51, 51, 1);
    titleNameLab.backgroundColor = [UIColor clearColor];
    titleNameLab.font=[UIFont systemFontOfSize:15.0];
    self.titleNameLabel = titleNameLab;
    [self addSubview:titleNameLab];
    RELEASE_SAFE(titleNameLab);
    
    UILabel *companyLab = [[UILabel alloc ]initWithFrame:
                    CGRectMake(self.titleNameLabel.frame.origin.x, self.titleNameLabel.frame.size.height
                               +self.titleNameLabel.frame.origin.y + 1, 95, 18)];
    companyLab.textAlignment = NSTextAlignmentLeft;
    companyLab.textColor = RGBACOLOR(102, 102, 102, 1);
    companyLab.backgroundColor = [UIColor clearColor];
    companyLab.font=[UIFont systemFontOfSize:12.0];
    self.companyLabel = companyLab;
    [self addSubview:companyLab];
    RELEASE_SAFE(companyLab);
}


- (void)dealloc
{
    self.companyLabel = nil;
    self.iconImageView = nil;
    self.titleNameLabel = nil;
    [super dealloc];
}


@end
