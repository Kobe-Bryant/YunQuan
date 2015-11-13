//
//  FirstCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "FirstCell.h"
#import "Global.h"

@implementation FirstCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(15, 10.0, 70, 20.0)];
        titleLab.backgroundColor = [UIColor clearColor];
        titleLab.font = [UIFont systemFontOfSize:14.0];
        titleLab.textColor = RGBACOLOR(51, 51, 51, 1);
        self.titleLable = titleLab;
        [self addSubview:titleLab];
        RELEASE_SAFE(titleLab);
        
        UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(70, 10, 240, 18.0)];
        contentLab.backgroundColor = [UIColor clearColor];
        contentLab.font = [UIFont systemFontOfSize:14.0];
        contentLab.numberOfLines = 0;
        contentLab.textColor = RGBACOLOR(136, 136, 136, 1);
        self.contentLable = contentLab;
        [self addSubview:contentLab];
        RELEASE_SAFE(contentLab);
        
    }
    return self;
}

- (void)dealloc{
    self.titleLable = nil;
    self.contentLable = nil;
    [super dealloc];
}

@end
