//
//  TextData.m
//  ql
//
//  Created by LazySnail on 14-5-7.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "TextData.h"

#define TextType        @"txttyp"
#define Text            @"txt"

@implementation TextData

@synthesize objtype = _objtype;

- (instancetype)init{
    self = [super init];
    if (self) {
        _objtype = DataMessageTypeText;
        _txttype = 1;
        _txt = @"";
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super initWithDic:dic];
    _objtype = DataMessageTypeText;
    
    if (self) {
        self.txttype = [[dic objectForKey:TextType]intValue];
        
        
        if ([self.dataDic objectForKey:Text] != nil) {
            self.txt = [self.dataDic  objectForKey:Text];
        } else {
            self.txt = @"";
        }
    }
    return self;
}

- (NSDictionary *)getDic{
    
    NSDictionary *dataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.txt,Text,
                             [NSNumber numberWithInt:self.txttype],TextType,nil];
    self.dataDic = dataDic;
    return [super getDic];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    TextData * theCopy = [[TextData alloc]init];
    theCopy.txt= [[self.txt copy] autorelease];
    theCopy.dataStatus = self.dataStatus;
    return theCopy;
}

- (NSString *)dataListDescreption
{
    return self.txt;
}

- (void)dealloc
{
    self.txt = nil;
    [super dealloc];
}

@end
