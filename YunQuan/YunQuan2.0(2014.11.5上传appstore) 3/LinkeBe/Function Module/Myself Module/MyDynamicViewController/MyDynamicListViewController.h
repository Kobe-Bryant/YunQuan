//
//  MyDynamicListViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-30.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDynamicListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray* cardsArr;
    
    UITableView* tableview;
    
    int type;
    
    NSNumber* ts;
    NSNumber* pageNumber;
}

@end
