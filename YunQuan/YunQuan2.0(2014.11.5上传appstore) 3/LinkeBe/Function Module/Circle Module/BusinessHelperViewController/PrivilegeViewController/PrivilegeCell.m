//
//  PrivilegeCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PrivilegeCell.h"
#import "Global.h"

@implementation PrivilegeCell
@synthesize iconImage,titleLable,backImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 300, 45)];
        self.backImage.image = [UIImage imageNamed:@""];
        [self addSubview:self.backImage];
        
        self.iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.backImage.frame) + 5, CGRectGetMinY(self.backImage.frame) + 5, 35, 35)];
        self.iconImage.image = [UIImage imageNamed:@""];
        [self addSubview:self.iconImage];
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImage.frame) + 5, CGRectGetMinY(self.iconImage.frame), self.backImage.bounds.size.width - 60, self.iconImage.bounds.size.height)];
        self.titleLable.font = [UIFont boldSystemFontOfSize:15.0];
        self.titleLable.textColor = [UIColor whiteColor];
        self.titleLable.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLable];
        
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(self.backImage);
    RELEASE_SAFE(self.iconImage);
    RELEASE_SAFE(self.titleLable);
    [super dealloc];
}


@end
