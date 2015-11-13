//
//  ContactModel.h
//  LinkeBe
//
//  Created by Dream on 14-9-23.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactModel : NSObject

@property (nonatomic, copy) NSString *iconStr;
@property (nonatomic, copy) NSString *nameStr;
@property (nonatomic, copy) NSString *positionStr;
@property (nonatomic, copy) NSString *companyStr;
@property (nonatomic, copy) NSString *sexString; //add vincent
@property (nonatomic, assign) long long userId;

@end
