//
//  DynamicEditManager.m
//  LinkeBe
//
//  Created by yunlai on 14-9-10.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "DynamicEditManager.h"

#import "DynamicEditDataProcess.h"

@implementation DynamicEditManager

-(void) accessDynamicEditPublish:(NSMutableDictionary *)dic dataList:(NSArray*) dataArr{
    [[LinkedBeHttpRequest shareInstance] requestPublishDynamicDelegate:self parameterDictionary:dic parameterArray:dataArr];
}

#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
    if (jsonDic) {
        int errcode = [[jsonDic objectForKey:@"errcode"] intValue];
        if (errcode != 0 && errcode != -2) {
            [Common checkProgressHUDShowInAppKeyWindow:[jsonDic objectForKey:@"errmsg"] andImage:nil];
            jsonDic = nil;
        }
    }else{
        [Common checkProgressHUDShowInAppKeyWindow:@"链接服务器失败" andImage:nil];
    }
    
    NSArray* arr = [DynamicEditDataProcess getDynamicEditPublishBackWith:jsonDic];
    [_delegate getDynamicEditHttpCallBack:arr interface:LinkedBe_Publish_dynamic];
    
    [self release];
}



@end
