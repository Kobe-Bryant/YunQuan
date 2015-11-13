//
//  OtherLinkCell.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-19.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCell.h"
#import "TQRichTextView.h"
#import "RegexKitLite.h"
#import "TQRichTextEmojiRun.h"

@interface OtherLinkCell : MessageCell

@property (nonatomic, retain) UIView *contentV;
@property (nonatomic, retain) UIView *bgView;
@property (nonatomic, retain) UIImageView * iconView;
@property (nonatomic, retain) UILabel* timeLab;
@property (nonatomic, retain) TQRichTextView * descriptionLabel;
@property (nonatomic, retain) TQRichTextView *msgTextView;

@end
