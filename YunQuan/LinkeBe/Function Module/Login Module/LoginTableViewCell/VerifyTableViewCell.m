//
//  VerifyTableViewCell.m
//  ql
//
//  Created by yunlai on 14-2-26.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "VerifyTableViewCell.h"
#import "Global.h"
#define kleftPadding 20.f
#define kpadding 25.f

@implementation VerifyTableViewCell
@synthesize usernameLabel = _usernameLabel;
@synthesize userPosition = _userPosition;
@synthesize headView = _headView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _headView = [[UIImageView alloc]initWithFrame:CGRectMake(kpadding, (88 - 60)/2, 60, 60)];
        _headView.userInteractionEnabled = YES;
        _headView.layer.cornerRadius = 5;
        _headView.clipsToBounds = YES;
        _headView.layer.borderWidth = 0.8;
        _headView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:_headView];
        
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxY(_headView.frame) + kleftPadding, kpadding, 200, 30)];
        _usernameLabel.backgroundColor = [UIColor clearColor];
        _usernameLabel.font = KQLboldSystemFont(20);
        [self.contentView addSubview:_usernameLabel];
        
        _userPosition = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxY(_headView.frame) + kleftPadding, CGRectGetMaxY(_usernameLabel.frame)-5, 200, 30)];
        _userPosition.backgroundColor = [UIColor clearColor];
        _userPosition.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.f];
        _userPosition.font = KQLSystemFont(16);
        _userPosition.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_userPosition];
    }
    return self;
}

- (void)dealloc
{
    RELEASE_SAFE(_userPosition);
    RELEASE_SAFE(_headView);
    RELEASE_SAFE(_usernameLabel);
    [super dealloc];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
