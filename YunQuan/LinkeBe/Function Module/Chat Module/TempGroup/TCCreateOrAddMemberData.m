//
//  TCCreateOrAddMemberData.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-8.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "TCCreateOrAddMemberData.h"
#import "ContactModel.h"

@implementation TCCreateOrAddMemberData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tempCircleID = 0;
    }
    return self;
}

- (instancetype)initWithIMAckDic:(NSDictionary *)dic
{
    self = [self init];
    if (self) {
        self.dataLocalID = [[dic objectForKey:@"locmid"]intValue];
        self.tempCircleID = [[dic objectForKey:@"gid"]longLongValue];
    }
    return self;
}

- (NSDictionary *)getiMSendDic
{
    NSMutableArray *idArray = [NSMutableArray arrayWithCapacity:0];
    for (ContactModel *model in self.memberArr) {
        [idArray addObject:[NSNumber numberWithLongLong:model.userId]];
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:self.dataLocalID],@"locmid",
                         idArray,@"uidlst",
                         nil];
    return dic;
}


@end
