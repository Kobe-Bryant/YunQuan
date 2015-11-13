//
//  TempChatMembersViewController.h
//  LinkeBe
//
//  Created by Dream on 14-10-17.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TypePush) {
    yellowViewType,
    tempChatDetailType
};

@interface TempChatMembersViewController : UIViewController

@property (nonatomic, retain) NSDictionary *membersDic;

@property (nonatomic, assign) TypePush typePush;

@end
