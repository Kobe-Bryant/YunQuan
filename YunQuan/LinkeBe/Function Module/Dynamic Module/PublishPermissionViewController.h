//
//  PublishPermissionViewController.h
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishPermissionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView* tableview;
    
    //数据源
    NSMutableArray* userArr;
}

@end
