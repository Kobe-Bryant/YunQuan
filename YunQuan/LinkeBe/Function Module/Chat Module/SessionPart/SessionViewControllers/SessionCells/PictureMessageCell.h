//
//  PictureMessageCell.h
//  ql
//
//  Created by LazySnail on 14-6-6.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "MessageCell.h"
#import "ImageBrowser.h"

@interface PictureMessageCell : MessageCell <ImageBrowserDelegate>

@property (nonatomic, retain) NSString * wholeImgUrlStr;
@property (nonatomic, retain) UIView * shadowBackView;

@end
