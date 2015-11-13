//
//  YLNullViewReminder.h
//  ql
//
//  Created by yunlai on 14-5-21.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLNullViewReminder : UIView

- (id)initWithFrame:(CGRect)frame
      reminderImage:(UIImage *)img
      reminderTitle:(NSString *)title;

- (void)removeReminder;

@end
