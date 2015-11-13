//
//  DetailSelectOrgViewController.h
//  LinkeBe
//
//  Created by Dream on 14-10-21.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailSelectOrgViewControllerDelegate <NSObject>

- (void)CallBackSureSelect:(NSMutableArray *)array;

@end

@interface DetailSelectOrgViewController : UIViewController

@property (nonatomic,assign) id <DetailSelectOrgViewControllerDelegate>delegate;


@end
