//
//  ObjectData.m
//  LinkeBe
//
//  Created by LazySnail on 14-1-28.
//  Copyright (c) 2014年 yunlai. All rights reserved.
//

#import "ObjectData.h"
#import "Circle_member_model.h"
#import "SecretarySingleton.h"
#import "OrgSingleton.h"
#import "MessageData.h"
#import "SBJson.h"
#import "TempChat_list_model.h"
#import "TempChatManager.h"
#import "SDImageCache.h"

typedef enum{
    ObjectDataTypeMale = 0,
    ObjectDataTypeFemale = 1,
    ObjectDataTypeTempCircle = 2 ,
    ObjectDataTypeOrg,
    ObjectDataTypeSecretary
}ObjectDataType;

@interface ObjectData ()
{
    
}

@property (nonatomic, assign) ObjectDataType type;

@end

@implementation ObjectData

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [self init];
    if (self) {
        self.objectID = [[dic objectForKey:@"uid"]longLongValue];
        self.objectName = [dic objectForKey:@"realname"];
        self.objectPortrait = [dic objectForKey:@"portrait"];
    }
    return self;
}

- (NSMutableDictionary *)getRestoreDic
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithLongLong:self.objectID],@"uid",
                                 self.objectName,@"realname",
                                 self.objectPortrait,@"portrait", nil];
    return dic;
}

+ (BOOL)isSpecialObjectWithObjectID:(long long)objectID
{
    BOOL specialJudger = objectID == [[SecretarySingleton shareSecretary]secretaryID] || objectID == [[OrgSingleton shareOrg]orgID];
    return specialJudger;
}

+ (ObjectData *)objectForLatestMessage:(MessageData *)latestMessage
{
    switch (latestMessage.sessionType) {
        case SessionTypePerson:
        {
            ObjectData * person = [ObjectData objectFromMemberListWithID:latestMessage.objectID];
            return person ;
        }
            break;
        case SessionTypeTempCircle:
        {
            ObjectData * tempCircle = [[ObjectData alloc]init];
            
            NSDictionary *tempCircleDic = [TempChat_list_model getTempChatContentDataWith:latestMessage.objectID];
            
            if (tempCircleDic == nil) {
                [[TempChatManager shareManager]retrieveTempCirleDetailWithTempCircleID:latestMessage.objectID andWaitingData:nil];
            }
        
            tempCircle.objectID = [[tempCircleDic objectForKey:@"id"] longLongValue];
            tempCircle.objectName = [tempCircleDic objectForKey:@"name"];
            tempCircle.objectPortrait = nil;
            tempCircle.type = ObjectDataTypeTempCircle;
            
            return [tempCircle autorelease];
        }
            break;
        default:
            break;
    }
}

+ (ObjectData *)speakerForSpekerID:(long long)spekerID
{
    ObjectData *speaker = [ObjectData objectFromMemberListWithID:spekerID];
   return speaker;
}

+ (ObjectData *)objectFromMemberListWithID:(long long)objectID
{
    ObjectData * person = [[ObjectData alloc]init];
    person.objectID = objectID;
    
    if (objectID == [[SecretarySingleton shareSecretary] secretaryID]) {
        person.objectName = [[SecretarySingleton shareSecretary]secretaryName];
        person.objectPortrait = [[SecretarySingleton shareSecretary]secretaryPortrait];
        person.type = ObjectDataTypeSecretary;
        person.orgUserID = [[SecretarySingleton shareSecretary]orgUserId];
    } else if (objectID == [[OrgSingleton shareOrg] orgID]){
        person.objectName = [[OrgSingleton shareOrg]orgName];
        person.objectPortrait = [[OrgSingleton shareOrg]orgPortrait];
        person.type = ObjectDataTypeOrg;
        person.orgUserID = [[OrgSingleton shareOrg]orgUserId];
    } else {
        NSDictionary * memberDic = [Circle_member_model getMemberDicWithUserID:objectID];
        
        NSString * name = [memberDic objectForKey:@"realname"];
        NSString * portraitStr = [memberDic objectForKey:@"portrait"];
        NSNumber * sex = [memberDic objectForKey:@"sex"];
        person.objectID = objectID;
        person.objectName = name;
        person.objectPortrait = portraitStr;
        person.orgUserID = [[memberDic objectForKey:@"orgUserId"]intValue];
        person.type = sex.intValue;
    }
   
    return [person autorelease];
}

- (UIImage *)getDefaultProtraitImg
{
    UIImage * portrait = nil;
    switch (self.type) {
        case ObjectDataTypeTempCircle:
        {
            portrait = [UIImage imageNamed:DEFAULT_TEMPCIRCLE_PORTRAIT];
        }
            break;
        case ObjectDataTypeMale:
        {
            portrait = [UIImage imageNamed:DEFAULT_MALE_PORTRAIT];
        }
            break;
        case ObjectDataTypeFemale:
        {
            portrait = [UIImage imageNamed:DEFAULT_FEMALE_PORTRAIT];
        }
            break;
        case ObjectDataTypeOrg:
        {
            portrait = [UIImage imageNamed:DEFAULT_ORG_PORTRAIT];
        }
            break;
        case ObjectDataTypeSecretary:
        {
            portrait = [UIImage imageNamed:DEFAULT_SECRETARY_PORTRAIT];
        }
            break;
        default:
            break;
    }
    return portrait;
}

- (id)copyWithZone:(NSZone *)zone
{
    ObjectData * newObject = [[ObjectData alloc]init];
    newObject.objectID = self.objectID;
    newObject.objectName = [[self.objectName copy]autorelease];
    newObject.objectPortrait = [[self.objectPortrait copy]autorelease];
    return newObject;
}

- (void)dealloc
{
    self.objectName = nil;
    self.objectPortrait = nil;
    [super dealloc];
}

@end
