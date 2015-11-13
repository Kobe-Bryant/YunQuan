//
//  BusinessView.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "BusinessView.h"
#import "Global.h"

@implementation BusinessView
@synthesize iconImage;
@synthesize titleLable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        CGRectMake(0*width + 20 , 15, width-30 , 90)
        self.iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 146, 116)];
        self.iconImage.backgroundColor = [UIColor clearColor];
        [self addSubview:self.iconImage];
        
        self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 146, 116)];
        self.titleLable.center = self.iconImage.center;
        self.titleLable.textColor = [UIColor whiteColor];
        self.titleLable.backgroundColor = [UIColor clearColor];
        self.titleLable.textAlignment = NSTextAlignmentCenter;
        self.titleLable.font = [UIFont boldSystemFontOfSize:16.0];
        [self addSubview:self.titleLable];

    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(self.iconImage);
    RELEASE_SAFE(self.titleLable);
    [super dealloc];
}

@end
