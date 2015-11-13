//
//  VoiceData.m
//  ql
//
//  Created by LazySnail on 14-6-26.
//  Copyright (c) 2014年 LuoHui. All rights reserved.
//

#import "VoiceData.h"

#define VoiceDurationStr        @"voilen"
#define VoiceDataUrl            @"url"

@implementation VoiceData

@synthesize objtype = _objtype;

- (instancetype)init{
    self = [super init];
    if (self) {
        _objtype = DataMessageTypeVoice;
        self.duration = 0;
        self.url = @"";
    }
    return self;
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super initWithDic:dic];
    if (self) {
        _objtype = DataMessageTypeVoice;
        
        
        if ([self.dataDic objectForKey:VoiceDurationStr] != nil) {
            self.duration = [[self.dataDic  objectForKey:VoiceDurationStr]intValue];
        } 
        
        if ([self.dataDic objectForKey:VoiceDataUrl]) {
            self.url = [self.dataDic  objectForKey:VoiceDataUrl];
        }
    }
    return self;
}

- (NSDictionary *)getDic{
    
    NSDictionary *dataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.url,VoiceDataUrl,
                             [NSNumber numberWithInt:self.duration],VoiceDurationStr,nil];
    self.dataDic = dataDic;
    
    return [self genterateComplateDic];
}

- (instancetype) copyWithZone:(NSZone *)zone
{
    VoiceData * theCopy = [VoiceData new];
    theCopy.dataStatus = self.dataStatus;
    theCopy.url = [[self.url copy] autorelease];
    return theCopy;
}

- (NSString *)dataListDescreption
{
    return @"[语音]";
}

- (void)dealloc
{
    self.url = nil;
    self.currentCell = nil;
    [super dealloc];
}

@end
