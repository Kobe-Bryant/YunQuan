//
//  SecondModel.m
//  LinkeBe
//
//  Created by Dream on 14-10-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "SecondModel.h"
#import "ThirdModel.h"

@implementation SecondModel

+ (BOOL)secondOrgIsSelected:(NSMutableArray *)array {
    BOOL isSelected = YES;
    if (array.count > 0) {
        for (ThirdModel *thrModel in array) {
            if (thrModel.selectedState == 2) {
                isSelected = NO;
                break;
            }
        }
    }
    return isSelected;
}

@end
