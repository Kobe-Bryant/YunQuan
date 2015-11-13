//
//  PATextView.h
//  PAEBank_iPad
//
//  Created by james lee on 12-1-11.
//  Copyright (c) 2012年 pingan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PATextFormatView : UIScrollView
{
    NSString *formatText;
    NSArray *formatViews;
    UIFont *font;
    UIColor *textColor;
}
@property(nonatomic,retain)NSString *formatText;
@property(nonatomic,retain)NSArray *formatViews;
@property(nonatomic,retain)UIFont *font;
@property(nonatomic,retain)UIColor *textColor;
@end
