//
//  PLYAuditor.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYAuditor.h"

@implementation PLYAuditor
{
   // The id of the user who created/updated the object
   NSString *userId;
   
   // The id of the application the object was created/updated with.
   NSString *appId;
   
   // The nickname of the user
   NSString *userNickname;
}

@synthesize userId;
@synthesize appId;
@synthesize userNickname;

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"pl-usr-id"]) {
        [self setValue:value forKey:@"userId"];
    } else if ([key isEqualToString:@"pl-app-id"]) {
        [self setValue:value forKey:@"appId"];
    } else if ([key isEqualToString:@"pl-usr-nickname"]) {
        [self setValue:value forKey:@"userNickname"];
    }
}

- (NSDictionary *) dictionaryRepresentation{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (userId != nil) {
        [dict setObject:userId forKey:@"pl-usr-id"];
    }
    if (appId != nil) {
        [dict setObject:appId forKey:@"pl-app-id"];
    }
    if (userNickname != nil) {
        [dict setObject:userNickname forKey:@"pl-usr-nickname"];
    }
    
    return dict;
}

@end
