//
//  CustomEmojiView.h
//  ql
//
//  Created by LazySnail on 14-9-14.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomEmojiViewDelegate <NSObject>

- (void)putEmojiString:(NSString *)str;

- (void)deleteString;

- (void)shouldTurnToNextEmoticon;

@end

@interface CustomEmojiView : UIView

@property (nonatomic ,assign) id <CustomEmojiViewDelegate> delegate;

+ (UIView *)getLastEmojiView;

- (instancetype)initWithLastView:(UIView *)lastView andFrame:(CGRect)frame;

- (void)scrollToLastView;

@end
