//
//  SnailLoopScrollView.h
//  ql
//
//  Created by LazySnail on 14-8-21.
//  Copyright (c) 2014年 Snail. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SnailLoopScrollViewDelegate <NSObject>

- (void)imageSelectedWithPageIndex:(NSInteger)index;

@end

@interface SnailLoopScrollView : UIView

@property(nonatomic, assign) BOOL isAutoLoopScroll;

@property(nonatomic, assign) float loopTimeInterval;

@property(nonatomic, assign) CGRect pageControlFrame;  //default is middle for the view

@property(nonatomic, assign) id <SnailLoopScrollViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andImageUrls:(NSArray *)imgs isAutoLoop:(BOOL)isAutoLoop loopTimeInterval:(float)timeInterval;

@end
