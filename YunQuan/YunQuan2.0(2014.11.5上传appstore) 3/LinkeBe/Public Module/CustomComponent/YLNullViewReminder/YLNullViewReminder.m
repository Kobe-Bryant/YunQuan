//
//  YLNullViewReminder.m
//  ql
//
//  Created by yunlai on 14-5-21.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "YLNullViewReminder.h"
#import "Global.h"

@implementation YLNullViewReminder


- (id)initWithFrame:(CGRect)frame
      reminderImage:(UIImage *)img
      reminderTitle:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *remiderImg = [[UIImageView alloc]init];
        remiderImg.frame = CGRectMake((CGRectGetWidth(frame) - 120.f)/ 2 , (CGRectGetHeight(frame) - 120.f)/ 2, 100.f, 120.f);
        remiderImg.image = img;
        [remiderImg setBackgroundColor:[UIColor clearColor]];
        [self addSubview:remiderImg];
        
        UILabel *signTitle  = [[UILabel alloc]init];
        signTitle.frame = CGRectMake(0.f , (CGRectGetHeight(frame) + 100)/ 2, ScreenWidth, 30.f);
        signTitle.textAlignment = NSTextAlignmentCenter;
        signTitle.text = title;
        signTitle.font = KQLSystemFont(15);
        signTitle.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.3f];
        [signTitle setBackgroundColor:[UIColor clearColor]];
        [self addSubview:signTitle];
        
        RELEASE_SAFE(remiderImg);
        RELEASE_SAFE(signTitle);
    }
    return self;
}

- (void)removeReminder{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
