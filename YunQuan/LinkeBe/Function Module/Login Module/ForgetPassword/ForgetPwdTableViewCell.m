//
//  ForgetPwdTableViewCell.m
//  LinkeBe
//
//  Created by yunlai on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ForgetPwdTableViewCell.h"
#import "Global.h"

@implementation ForgetPwdTableViewCell

@synthesize loginField = _loginField;
@synthesize getAuthCode = _getAuthCode;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _loginField = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, ScreenWidth-90, 50)];
        _loginField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//字体垂直居中对齐
        _loginField.font = [UIFont systemFontOfSize:15];
        _loginField.backgroundColor =[UIColor clearColor];
        [_loginField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_loginField setKeyboardType:UIKeyboardTypeNumberPad];
        [self.contentView addSubview:_loginField];
        
        _getAuthCode = [UIButton buttonWithType:UIButtonTypeCustom];
        _getAuthCode.frame = CGRectMake(ScreenWidth-90, 0, 90, 50);
        _getAuthCode.titleLabel.font = KQLSystemFont(15);
        [_getAuthCode setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_getAuthCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getAuthCode setBackgroundColor:RGBACOLOR(26,161,230,1)];
        [self.contentView addSubview:_getAuthCode];
        
        // 分割线
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 49.f, ScreenWidth, 1.0f)];
        //        line.backgroundColor = [[ThemeManager shareInstance] getColorWithName:@"COLOR_LINE"];
        line.backgroundColor = [UIColor colorWithRed:232/255.0 green:237/255.0 blue:241/255.0 alpha:1.f];
        [self.contentView addSubview:line];
        RELEASE_SAFE(line);
    }
    return self;
}

- (void)dealloc
{
    //    RELEASE_SAFE(_iconV);
    RELEASE_SAFE(_loginField);
    [super dealloc];
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

@end
