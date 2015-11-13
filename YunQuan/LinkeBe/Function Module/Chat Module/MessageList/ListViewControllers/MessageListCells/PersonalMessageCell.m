//
//  personalmessageCell.m
//  ql
//
//  Created by yunlai on 14-3-3.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import "PersonalmessageCell.h"
#import "UIImageView+WebCache.h"
#import "MessageListData.h"
#import "SBJson.h"

@interface PersonalMessageCell ()
{
    
}
@property (nonatomic, assign) SDImageCache * imageCache;

@end

@implementation PersonalMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.imageCache = [SDImageCache sharedImageCache];
    return self;
}

- (void)freshWithInfoDic:(MessageListData *)listData{

    [super freshWithInfoDic:listData];
}

- (void)freshWithInfoDic:(MessageListData *)listData searchText:(NSString *)searchStr{
    
    [super freshWithInfoDic:listData searchText:searchStr];
}

@end
