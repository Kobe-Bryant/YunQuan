//
//  SessionViewController.h
//  ql
//
//  Created by yunlai on 14-3-8.
//  Copyright (c) 2014年 ChenFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBImagePickerController.h"
#import "SnailMessageViewController.h"
#import "EGORefreshTableHeaderView.h"

typedef NS_ENUM(NSInteger, ChatType) {
   TabbarChatType,
   NormalChatType
};

@protocol SessionViewDelegate <NSObject>

- (void)callBackPassMembers:(NSMutableArray *)array;

@end

@class MessageListData;

@interface SessionViewController : SnailMessageViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,QBImagePickerControllerDelegate,EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView* headerView;
}

@property (nonatomic, assign) ChatType chatType;

@property (nonatomic, assign) id <SessionViewDelegate> sessionDelegate;

@property (nonatomic, retain) MessageListData * listData;
@property (nonatomic, retain) NSMutableArray * circleContactsList;
@property (nonatomic, assign) BOOL isPopToRootViewController;
@property (nonatomic, assign) BOOL isShowRightButtom;


@end
