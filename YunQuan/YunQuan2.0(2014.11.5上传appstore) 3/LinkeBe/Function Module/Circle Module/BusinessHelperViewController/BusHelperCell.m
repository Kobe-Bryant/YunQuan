//
//  BusHelperCell.m
//  LinkeBe
//
//  Created by Dream on 14-9-15.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "BusHelperCell.h"
#import "Global.h"

@implementation BusHelperCell
@synthesize leftView;
@synthesize rightView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = RGBACOLOR(249, 249, 249, 1);
        
        NSInteger width = ScreenWidth/2;
        self.leftView = [[BusinessView alloc] initWithFrame:CGRectMake(0*width + 12 , 15, width-20 , 116)];
        self.leftView.clipsToBounds = YES;
        [self addSubview:leftView];
        
        self.rightView = [[BusinessView alloc] initWithFrame:CGRectMake(1*width + 8, self.leftView.frame.origin.y, self.leftView.frame.size.width , self.leftView.frame.size.height)];
        self.rightView.clipsToBounds = YES;
        [self addSubview:rightView];
    }
    return self;
}


- (void)dealloc
{
    RELEASE_SAFE(self.leftView);
    RELEASE_SAFE(self.rightView);
    
    [super dealloc];
}

@end
