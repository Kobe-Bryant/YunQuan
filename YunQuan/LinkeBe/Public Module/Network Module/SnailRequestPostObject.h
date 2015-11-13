//
//  SnailRequestPostObject.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnailRequestObject.h"

@interface SnailRequestPostObject : SnailRequestObject

//单个上传
@property (nonatomic, retain) NSData * postData;
//多个上传
@property (nonatomic, retain) NSArray * postDataArr;

@end
