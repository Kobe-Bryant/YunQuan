//
//  ForgetPwdTableViewCell.h
//  LinkeBe
//
//  Created by yunlai on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPwdTableViewCell : UITableViewCell{
    UITextField *_loginField;
    UIButton *_getAuthCode;
}
@property (nonatomic, retain) UITextField *loginField;
@property (nonatomic, retain) UIButton *getAuthCode;
@end
