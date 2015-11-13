//
//  PopViewCell.m
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "PopViewCell.h"

#import "DynamicCommon.h"

@implementation PopViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setUp];
    }
    return self;
}

-(void) setUp{
    UIImageView* imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 4, 32, 32)];
    self.imageV = imgV;
    [self.contentView addSubview:imgV];
    [imgV release];
    
    UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageV.frame) + 4, 0, 60, 40)];
    lab.font = [UIFont systemFontOfSize:15];
    lab.textColor = [UIColor whiteColor];
    if (!IOS7_OR_LATER) {
        lab.backgroundColor = [UIColor clearColor];
    }
    lab.textAlignment = NSTextAlignmentCenter;
    self.titleLab = lab;
    [self.contentView addSubview:lab];
    [lab release];
}

-(void) initWithData:(NSDictionary *)dic{
    self.imageView.image = IMGREADFILE([dic objectForKey:@"image"]);
    self.titleLab.text = [dic objectForKey:@"title"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) dealloc{
    [_imageV release];
    [_titleLab release];
    
    [super dealloc];
}

@end
