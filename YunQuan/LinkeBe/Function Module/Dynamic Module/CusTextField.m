//
//  CusTextField.m
//  ql
//
//  Created by yunlai on 14-8-18.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "CusTextField.h"

@implementation CusTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(CGRect) textRectForBounds:(CGRect)bounds{
    return CGRectMake(bounds.origin.x + 15, bounds.origin.y, bounds.size.width - 30, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(bounds.origin.x + 15, bounds.origin.y, bounds.size.width - 30, bounds.size.height);
}

@end
