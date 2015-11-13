//
//  ContactView.m
//  LinkeBe
//
//  Created by Dream on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ContactView.h"
#import "Global.h"

@implementation ContactView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        UIScrollView *scrollVc = [[UIScrollView alloc]initWithFrame:CGRectMake(0, (55 - 44)/2, 250, 44)];
        UIImageView *defaultImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 44, 44)];
        defaultImage.image = [UIImage imageNamed:@"btn_chat_dotted.png"];
        [scrollVc addSubview:defaultImage];
        scrollVc.showsVerticalScrollIndicator = NO;
        self.scrollView = scrollVc;
        [self addSubview:scrollVc];
         RELEASE_SAFE(defaultImage);
        RELEASE_SAFE(scrollVc);
        
    
        _surreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _surreButton.frame = CGRectMake(CGRectGetMaxX(self.scrollView.frame) + 5, (55 - 35)/2, 50, 35);
        _surreButton.backgroundColor = [UIColor colorWithRed:0.12 green:0.55 blue:0.89 alpha:1.0];
        [_surreButton setTitle:@"确定" forState:UIControlStateNormal];
        _surreButton.layer.cornerRadius = 5.0;
        [self addSubview:_surreButton];
        
        UILabel *redLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.surreButton.frame) - 10, CGRectGetMinY(self.scrollView.frame), 20, 20)];
        redLab.backgroundColor = [UIColor colorWithRed:0.96 green:0.30 blue:0.33 alpha:1.0];
        redLab.textAlignment = NSTextAlignmentCenter;
        redLab.textColor = [UIColor whiteColor];
        redLab.font = [UIFont systemFontOfSize:13];
        redLab.layer.cornerRadius = redLab.bounds.size.height/2;
        redLab.layer.masksToBounds = YES;
        redLab.hidden = YES;
        self.redLable = redLab;
        [self addSubview:redLab];
        RELEASE_SAFE(redLab);
    }
    return self;
}

- (void)dealloc
{
    self.scrollView = nil;
    self.redLable = nil;
    [super dealloc];
}


@end
