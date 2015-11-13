//
//  wantHaveData.m
//  ql
//
//  Created by yunlai on 14-6-18.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "IWantData.h"


#define IWantDescription        @"cont"

@implementation IWantData

@synthesize objtype = _objtype;

-(instancetype) init{
    if (self = [super init]) {
        _objtype = DataMessageTypeIWant;
        _tbdesc = @"";
        _tburl = @"";
        self.dataID = 0;
        _txt = @"";
        _msgdesc = @"";
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super initWithDic:dic];
    
    if (self){
        _objtype = DataMessageTypeIWant;
        self.tbdesc = [self.dataDic objectForKey:@"tbdesc"];
        self.tburl = [self.dataDic objectForKey:@"tburl"];
        self.dataID = [[self.dataDic objectForKey:@"id"]intValue];
        self.msgdesc = [self.dataDic objectForKey:IWantDescription];
        self.txt = [self.dataDic objectForKey:@"txt"];
    }
    return self;
}

-(NSDictionary*) getDic{
    NSDictionary* dataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:self.dataID],@"id",
                             self.tbdesc ,@"tbdesc",
                            self.txt,@"txt",
                             self.msgdesc,IWantDescription,
                             self.tburl,@"tburl",
                             nil];
    
    self.dataDic = dataDic;
    return [self genterateComplateDic];
}

- (NSString *)dataListDescreption
{
    return [NSString stringWithFormat:@"[我要]%@",self.txt];
}

- (id)copyWithZone:(NSZone *)zone
{
    IWantData * newData = [[IWantData alloc]init];
    newData.dataID = self.dataID;
    newData.tbdesc = [[self.tbdesc copy] autorelease];
    newData.tburl = [[self.tburl copy] autorelease];
    newData.txt = [[self.txt copy]autorelease];
    newData.msgdesc = [[self.msgdesc copy] autorelease];
    newData.dataStatus = self.dataStatus;
    
    return newData;
}

- (void)dealloc
{
    self.txt = nil;
    self.tbdesc = nil;
    self.tburl = nil;
    self.msgdesc = nil;
    [super dealloc];
}

@end
