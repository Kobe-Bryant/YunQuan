//
//  LoginTableViewCell.m
//  LinkeBe
//
//  Created by yunlai on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "LoginTableViewCell.h"
#import "Global.h"

@implementation LoginTableViewCell
@synthesize loginField = _loginField;
@synthesize ico_clearImageView = _ico_clearImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _loginField = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, 205, 48)];
        _loginField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//字体垂直居中对齐
        _loginField.font = [UIFont systemFontOfSize:16];
        _loginField.backgroundColor =[UIColor clearColor];
//        [_loginField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_loginField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
        [self.contentView addSubview:_loginField];
        
        UIImage *clearImage = [UIImage imageNamed:Common_GuidePage_IcoClearImage];
        _ico_clearImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_loginField.frame.size.width+_loginField.frame.origin.x, (_loginField.frame.size.height-clearImage.size.height)/2, clearImage.size.width, clearImage.size.height)];
        _ico_clearImageView.image = clearImage;
        _ico_clearImageView.highlightedImage = [UIImage imageNamed:Common_GuidePage_IcoClearHightImage];
        
        _ico_clearImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_ico_clearImageView];
        
        // 分割线
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 49.f, ScreenWidth, 1.0f)];
        //        line.backgroundColor = [[ThemeManager shareInstance] getColorWithName:@"COLOR_LINE"];
        line.backgroundColor = [UIColor colorWithRed:232/255.0 green:237/255.0 blue:241/255.0 alpha:1.f];
        [self.contentView addSubview:line];
        RELEASE_SAFE(line);

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc{
    RELEASE_SAFE(_loginField);
    RELEASE_SAFE(_ico_clearImageView);
    [super dealloc];
}

@end
