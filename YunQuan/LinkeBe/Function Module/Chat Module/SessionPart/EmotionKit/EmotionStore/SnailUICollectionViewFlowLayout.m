//
//  SnailUICollectionViewFlowLayout.m
//  ql
//
//  Created by LazySnail on 14-8-25.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "SnailUICollectionViewFlowLayout.h"

const float kSnailEmotionImageViewSizeWidth = 60;
const float kSnailEmotionImageViewSizeHight = 85;
const float kSnailEmotionMinimumLineSpacing = 16;

@implementation SnailUICollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = CGSizeMake(kSnailEmotionImageViewSizeWidth, kSnailEmotionImageViewSizeHight);
        self.minimumLineSpacing = kSnailEmotionMinimumLineSpacing;
        self.sectionInset = UIEdgeInsetsMake(kSnailEmotionMinimumLineSpacing - 4, kSnailEmotionMinimumLineSpacing, 0, kSnailEmotionMinimumLineSpacing);
        self.collectionView.alwaysBounceHorizontal = YES;
    }
    return self;
}

@end
