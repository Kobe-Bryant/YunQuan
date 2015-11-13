//
//  EncryptionFile.m
//  LinkeBe
//
//  Created by yunlai on 14-9-24.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "EncryptionFile.h"
#import "UserModel.h"
#import "GTMBase64.h"

@implementation EncryptionFile

+(NSString*)encryptionString{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@",@"ddff8a809493f5833f7b3b61f5d46afa",@"c735dc38992e40dbb38b5fe60419277c"];//[UserModel shareUser].clientIdString, [UserModel shareUser].clientSecretString];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString* base64Str = [authData base64Encoding];
    const char* ascStr = [base64Str cStringUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %s",ascStr];
    return authValue;
}

@end
