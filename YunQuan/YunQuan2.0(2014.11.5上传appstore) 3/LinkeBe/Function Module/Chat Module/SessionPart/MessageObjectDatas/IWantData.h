//
//  wantHaveData.h
//  ql
//
//  Created by yunlai on 14-6-18.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "OriginData.h"

@interface IWantData : OriginData

//缩略图名
@property(nonatomic,assign) int dataID;
@property(nonatomic,retain) NSString* tbdesc;
@property(nonatomic,retain) NSString* tburl;
@property(nonatomic,retain) NSString* txt;
@property(nonatomic,retain) NSString* msgdesc;

@end
