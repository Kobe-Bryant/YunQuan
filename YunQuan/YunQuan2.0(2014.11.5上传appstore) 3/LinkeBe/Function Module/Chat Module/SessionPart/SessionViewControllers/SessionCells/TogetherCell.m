//
//  TogetherCell.m
//  ql
//
//  Created by yunlai on 14-8-20.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "TogetherCell.h"
#import "TogetherData.h"
#import "MessageData.h"

@interface TogetherCell ()
{
    
}



@end

@implementation TogetherCell



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
