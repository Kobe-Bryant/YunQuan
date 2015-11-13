//
//  GuidePageMessageManager.m
//  LinkeBe
//
//  Created by yunlai on 14-9-25.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "GuidePageMessageManager.h"
#import "LinkedBeHttpRequest.h"

@implementation GuidePageMessageManager

-(void) accessGuidePageMessageData:(NSMutableDictionary*) loginDic requestType:(LinkedBe_RequestType)requestType{

      [[LinkedBeHttpRequest shareInstance] requestSystemIndexDelegate:self parameterDictionary:loginDic parameterArray:nil parameterString:nil];
}


#pragma mark - httpback
-(void)didFinishCommand:(NSDictionary *)jsonDic cmd:(int)commandid withVersion:(int)ver{
        switch (commandid) {
        case LinkedBe_System_Index:
        {
//            guidePageArray = [jsonDic objectForKey:@"pics"];
            [_delegate getGuidePageMessageHttpCallBack:nil guideDic:jsonDic interface:commandid];
        }
            break;
        default:
            break;
    }
}

@end
