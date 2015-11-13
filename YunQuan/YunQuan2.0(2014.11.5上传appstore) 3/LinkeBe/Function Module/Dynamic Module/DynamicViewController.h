//
//  DynamicViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    NSMutableArray* cardsArr;
    
    UITableView* tableview;
    
    int type;
}

@end
