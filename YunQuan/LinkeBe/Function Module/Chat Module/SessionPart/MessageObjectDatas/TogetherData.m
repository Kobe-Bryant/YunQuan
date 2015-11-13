//
//  TogetherData.m
//  ql
//
//  Created by yunlai on 14-8-20.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "TogetherData.h"

#define TogetherID          @"id"
#define TogetherDescription @"cont"
#define Comment             @"txt"

@implementation TogetherData

@synthesize objtype = _objtype;

-(instancetype) init{
    if (self = [super init]) {
        _objtype = DataMessageTypeTogether;
        self.dataID = 0;
        self.txt = @"";
        self.msgdesc = @"";
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super initWithDic:dic];
    if (self){
        _objtype = DataMessageTypeTogether;
        self.dataID = [[self.dataDic objectForKey:TogetherID]intValue];
        _msgdesc = [self.dataDic objectForKey:TogetherDescription];
        _txt = [self.dataDic objectForKey:Comment];
    }
    return self;
}

-(NSDictionary*) getDic{
    NSDictionary* dataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:self.dataID],TogetherID,
                             self.txt,Comment,
                             self.msgdesc,TogetherDescription,
                             nil];
    self.dataDic = dataDic;
    
    return [self genterateComplateDic];
}

- (NSString *)dataListDescreption
{
    return @"[聚一聚消息]";
}

- (id)copyWithZone:(NSZone *)zone
{
    TogetherData * newData = [[TogetherData alloc]init];
    newData.dataID = self.dataID;
    newData.txt = [[self.txt copy]autorelease];
    newData.msgdesc = [[self.msgdesc copy] autorelease];
    newData.dataStatus = self.dataStatus;
    
    return newData;
}

- (void)dealloc
{
    self.txt = nil;
    self.msgdesc = nil;
    [super dealloc];
}

@end
