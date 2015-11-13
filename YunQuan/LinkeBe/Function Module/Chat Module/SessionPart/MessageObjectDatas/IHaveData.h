//
//  IHaveData.h
//  LinkeBe
//
//  Created by LazySnail on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "OriginData.h"

@interface IHaveData : OriginData

//缩略图名
@property(nonatomic,assign) int dataID;
@property(nonatomic,retain) NSString* tbdesc;
@property(nonatomic,retain) NSString* tburl;
@property(nonatomic,retain) NSString* txt;
@property(nonatomic,retain) NSString* msgdesc;

@end
