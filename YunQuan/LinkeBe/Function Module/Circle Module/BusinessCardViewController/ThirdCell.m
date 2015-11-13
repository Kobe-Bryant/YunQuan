//
//  ThirdCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ThirdCell.h"
#import "Global.h"

#define RMarginX 0
#define RMarginY 0
@implementation ThirdCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initSubCollectionsCell];
    }
    return self;
}

-(void)initSubCollectionsCell
{
    NSInteger width = ScreenWidth/2;
    _leftView = [[ThirdView alloc] initWithFrame:CGRectMake(0*width + RMarginX, RMarginY, width - 2*RMarginX, 155 - 2*RMarginY)];
    [self.contentView addSubview:_leftView];
    
    _rightView = [[ThirdView alloc] initWithFrame:CGRectMake(1*width + RMarginX, RMarginY, width - 2*RMarginX, 155 - 2*RMarginY)];
    self.rightView.clipsToBounds = YES;
    [self.contentView addSubview:_rightView];
    
}

- (void)dealloc
{
    [_leftView release]; _leftView = nil;
    [_rightView release]; _rightView = nil;
    [super dealloc];
}



@end
