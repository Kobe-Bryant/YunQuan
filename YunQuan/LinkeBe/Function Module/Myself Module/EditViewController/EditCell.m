//
//  EditCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "EditCell.h"
#import "Global.h"

@implementation EditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 70,20)];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.textColor = RGBACOLOR(136, 136, 136, 1);
        titleLab.font = [UIFont systemFontOfSize:14.0];
        self.titleLable = titleLab;
        [self addSubview:titleLab];
        RELEASE_SAFE(titleLab);
        
        UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(70, 10, 220, 18)];
        contentLab.numberOfLines = 0;
        contentLab.backgroundColor = [UIColor clearColor];
        contentLab.textColor = RGBACOLOR(52 , 52, 52, 1);
        contentLab.font = [UIFont systemFontOfSize:14.0];
        self.contentLable = contentLab;
        [self addSubview:contentLab];
        RELEASE_SAFE(contentLab);
    }
    return self;
}

- (void)dealloc
{
    self.titleLable = nil;
    self.contentLable = nil;
    [super dealloc];
}

@end
