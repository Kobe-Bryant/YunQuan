//
//  PictureData.m
//  ql
//
//  Created by LazySnail on 14-5-7.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "PictureData.h"

#define PictureUrl          @"url"
#define PictureThumbnail    @"tburl"
#define PictureWidth        @"w"
#define PictureHeight       @"h"

@implementation PictureData

@synthesize objtype = _objtype;

- (id)init{
    self = [super init];
    if (self) {
        _objtype = DataMessageTypePicture;
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super initWithDic:dic];
    _objtype = DataMessageTypePicture;
    if (self) {
        
        self.tburl = [self.dataDic objectForKey:PictureThumbnail];
        self.url = [self.dataDic objectForKey:PictureUrl];
    }
    return self;
}

- (NSDictionary *)getDic{
    NSDictionary * dataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.tburl,PictureThumbnail,
                              self.url,PictureUrl,
                              [NSNumber numberWithFloat:self.width],@"w",
                              [NSNumber numberWithFloat:self.height],@"h",
                              nil];
    self.dataDic = dataDic;
    
    return [self genterateComplateDic];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    PictureData * theCopy = [[PictureData alloc]init];
    theCopy.tburl = [[self.tburl copy] autorelease];
    theCopy.url = [[self.url copy] autorelease];
    theCopy.dataStatus = self.dataStatus;
    theCopy.width = self.width;
    theCopy.height = self.height;
    return theCopy;
}

- (NSString *)dataListDescreption
{
    return @"[图片]";
}

- (void)dealloc
{
    self.tburl = nil;
    self.url = nil;
    self.image = nil;
    [super dealloc];
}
@end
