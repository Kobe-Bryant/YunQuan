//
//  PrivilegeHeaderView.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PrivilegeHeaderView.h"
#import "Global.h"

@implementation PrivilegeHeaderView
@synthesize bgImageView;
@synthesize iconImage;
@synthesize nameLable;
@synthesize positionLable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        bgImageView = [[UIImageView alloc] init];
        bgImageView.frame = frame;
        [self addSubview:bgImageView];
        
        UIImage *image = [UIImage imageNamed:@"ico_default_portrait_female.png"];
        self.iconImage = [[UIImageView alloc] init];
        self.iconImage.frame = CGRectMake(20, self.frame.size.height - 50, image.size.height, image.size.width);
        [self addSubview:self.iconImage];
        
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImage.frame) + 15, CGRectGetMinY(self.iconImage.frame), 100, 20)];
        self.nameLable.backgroundColor = [UIColor clearColor];
        self.nameLable.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:self.nameLable];
        
        self.positionLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImage.frame) + 15, CGRectGetMinY(self.iconImage.frame) + 20, 100, 15)];
        self.positionLable.backgroundColor = [UIColor clearColor];
        self.positionLable.font = [UIFont boldSystemFontOfSize:14.0];
        [self addSubview:self.positionLable];
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(self.iconImage);
    RELEASE_SAFE(self.nameLable);
    RELEASE_SAFE(self.positionLable);
    [super dealloc];
}

@end
