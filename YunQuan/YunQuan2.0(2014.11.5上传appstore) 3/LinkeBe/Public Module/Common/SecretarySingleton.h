//
//  SecretorySingleton.h
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecretarySingleton : NSObject

@property (nonatomic, assign) long long secretaryID;

@property (nonatomic, assign) int orgUserId;

@property (nonatomic, retain) NSString * secretaryName;

@property (nonatomic, retain) NSString * secretaryPortrait;

+ (SecretarySingleton *)shareSecretary;

@end
