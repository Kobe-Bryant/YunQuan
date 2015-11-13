//
//  IHaveData.m
//  LinkeBe
//
//  Created by LazySnail on 14-9-22.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "IHaveData.h"

#define IHaveDescription            @"cont"

@implementation IHaveData

@synthesize objtype = m_objtype;

-(instancetype) init{
    if (self = [super init]) {
        m_objtype  = DataMessageTypeIHave;
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
        m_objtype = DataMessageTypeIHave;

        self.tbdesc = [self.dataDic objectForKey:@"tbdesc"];
        self.tburl = [self.dataDic objectForKey:@"tburl"];
        self.dataID = [[self.dataDic objectForKey:@"id"]intValue];
        self.msgdesc = [self.dataDic objectForKey:IHaveDescription];
        self.txt = [self.dataDic objectForKey:@"txt"];
    }
    return self;
}

-(NSDictionary*) getDic{
    NSDictionary* dataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:self.dataID],@"id",
                             self.txt,@"txt",
                             self.msgdesc,IHaveDescription,
                             self.tbdesc,@"tbdesc",
                             self.tburl,@"tburl",
                             nil];
    
    self.dataDic = dataDic;
    return [self genterateComplateDic];
}

- (NSString *)dataListDescreption
{
    return [NSString stringWithFormat:@"[我有]%@",self.txt];
}

- (id)copyWithZone:(NSZone *)zone
{
    IHaveData * newData = [[IHaveData alloc]init];
    newData.dataID = self.dataID;
    newData.tbdesc = [[self.tbdesc copy]autorelease];
    newData.tburl = [[self.tburl copy]autorelease];
    newData.txt = [[self.txt copy]autorelease];
    newData.msgdesc = [[self.msgdesc copy]autorelease];
    newData.dataStatus = newData.dataStatus;
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
