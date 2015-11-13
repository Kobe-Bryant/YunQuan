//
//  SnailTopLoopCell.h
//  ql
//
//  Created by LazySnail on 14-9-13.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailTopLoopCell : UITableViewCell

@property (nonatomic, retain) UIView * scorllLoopView;

- (void)refreshCellWithImgArray:(NSMutableArray *)imgArray;

@end
