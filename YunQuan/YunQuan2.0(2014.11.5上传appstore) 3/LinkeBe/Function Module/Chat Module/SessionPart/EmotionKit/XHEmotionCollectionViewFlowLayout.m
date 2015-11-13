//
//  XHEmotionCollectionViewFlowLayout.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionCollectionViewFlowLayout.h"
#import "ChatMacro.h"

@implementation XHEmotionCollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.itemSize = CGSizeMake(kXHEmotionImageViewSize, kXHEmotionImageViewSize + 10);
        self.minimumLineSpacing = kXHEmotionMinimumLineSpacing;
        self.sectionInset = UIEdgeInsetsMake(kXHEmotionMinimumLineSpacing - 4, kXHEmotionMinimumLineSpacing, 0, kXHEmotionMinimumLineSpacing);
    }
    return self;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(KUIScreenWidth * self.pages, 150);
}

@end
