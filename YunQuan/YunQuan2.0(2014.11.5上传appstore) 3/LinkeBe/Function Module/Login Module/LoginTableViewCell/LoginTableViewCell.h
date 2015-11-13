//
//  LoginTableViewCell.h
//  LinkeBe
//
//  Created by yunlai on 14-9-12.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTableViewCell : UITableViewCell
{
    UITextField *_loginField;
}
@property (nonatomic, retain) UITextField *loginField;
@property (nonatomic, retain) UIImageView *ico_clearImageView;

@end
