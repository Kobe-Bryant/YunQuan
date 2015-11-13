//
//  TempChatNameViewController.h
//  LinkeBe
//
//  Created by Dream on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TempChatNameDelegate <NSObject>

- (void)callBackChatName:(NSString *)string;

@end

@interface TempChatNameViewController : UIViewController

@property (nonatomic, assign) id <TempChatNameDelegate>delegate;

@property (nonatomic,assign) long long circleId; //会话ID

@property (nonatomic,copy) NSString *title; //会话名称

@end
