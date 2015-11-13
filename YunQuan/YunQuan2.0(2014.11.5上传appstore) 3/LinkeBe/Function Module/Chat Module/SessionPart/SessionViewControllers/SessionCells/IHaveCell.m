//
//  wantHaveInfoCell.m
//  ql
//
//  Created by yunlai on 14-6-18.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "IHaveCell.h"
#import "IHaveData.h"
#import "MessageData.h"

@implementation IHaveCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)freshWithInfoData:(MessageData *)data
{
    [super freshWithInfoData:data];
}

@end
