//
//  PopViewCell.h
//  LinkeBe
//
//  Created by yunlai on 14-9-16.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopViewCell : UITableViewCell

@property(nonatomic,retain) UIImageView* imageV;
@property(nonatomic,retain) UILabel* titleLab;

-(void) initWithData:(NSDictionary*) dic;

@end
