//
//  WarmTipsViewController.h
//  ql
//
//  Created by yunlai on 14-2-22.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

typedef enum{
    NoAcoutTips = 0,
    ToolTips,
    PriTips,
    FeedbackTips
}TIPSType;

@interface WarmTipsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HPGrowingTextViewDelegate>
{
    NSMutableArray *_listArray;
    UITableView *_chatTabelView;
}

@property (nonatomic ,retain) UITableView *chatTabelView;
@property (nonatomic ,retain) NSMutableArray *listArray;
@property (nonatomic ,retain) NSString *tipsString;

@property(nonatomic) TIPSType ttype;

@end
