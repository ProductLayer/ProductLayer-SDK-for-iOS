//
//  PLYUser.m
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYUser.h"

#import "DTLog.h"

#import "PLYAuditor.h"

@implementation PLYUser

@synthesize Class;
@synthesize Id;
@synthesize version;

@synthesize createdBy;
@synthesize createdTime;
@synthesize updatedBy;
@synthesize updatedTime;

@synthesize nickname;

@synthesize firstName;
@synthesize lastName;

@synthesize email;
@synthesize birthday;
@synthesize gender;

@synthesize points;
@synthesize unlockedAchievements;

@synthesize followerCount;
@synthesize followingCount;

@synthesize avatarUrl;

@synthesize followed;
@synthesize following;

+ (NSString *) classIdentifier{
    return @"com.productlayer.core.domain.beans.User";
}

+ (PLYUser *)instanceFromDictionary:(NSDictionary *)aDictionary {
    
    NSString *class = [aDictionary objectForKey:@"pl-class"];
    
    // Check if class identifier is valid for parsing.
    if(class != nil && [class isEqualToString: [PLYUser classIdentifier]]){
        PLYUser *instance = [[PLYUser alloc] init];
        [instance setAttributesFromDictionary:aDictionary];
        return instance;
    }
    
    DTLogError(@"No valid classIdentifier found for PLYUser in dictionary: %@", aDictionary);
    
    return nil;
}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {
    
    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    [self setValuesForKeysWithDictionary:aDictionary];
    
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"pl-created-by"]) {
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.createdBy = [PLYAuditor instanceFromDictionary:value];
        }
        
    } else if ([key isEqualToString:@"pl-app"] || [key isEqualToString:@"pl-usr-roles"]) {
        // Do nothing
    } else if ([key isEqualToString:@"pl-upd-by"]) {
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.updatedBy = [PLYAuditor instanceFromDictionary:value];
        }
    } else {
        [super setValue:value forKey:key];
    }
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"pl-class"]) {
        [self setValue:value forKey:@"Class"];
    } else if ([key isEqualToString:@"pl-id"]) {
        [self setValue:value forKey:@"Id"];
    }  else if ([key isEqualToString:@"pl-version"]) {
        [self setValue:value forKey:@"version"];
    } else if ([key isEqualToString:@"pl-created-by"]) {
        [self setValue:value forKey:@"createdBy"];
    } else if ([key isEqualToString:@"pl-created-time"]) {
        [self setValue:value forKey:@"createdTime"];
    } else if ([key isEqualToString:@"pl-upd-by"]) {
        [self setValue:value forKey:@"updatedBy"];
    } else if ([key isEqualToString:@"pl-upd-time"]) {
        [self setValue:value forKey:@"updatedTime"];
    }
    
    else if ([key isEqualToString:@"pl-usr-nickname"]) {
        [self setValue:value forKey:@"nickname"];
    } else if ([key isEqualToString:@"pl-usr-fname"]) {
        [self setValue:value forKey:@"firstName"];
    }  else if ([key isEqualToString:@"pl-usr-lname"]) {
        [self setValue:value forKey:@"lastName"];
    } else if ([key isEqualToString:@"pl-usr-email"]) {
        [self setValue:value forKey:@"email"];
    } else if ([key isEqualToString:@"pl-usr-bday"]) {
        [self setValue:value forKey:@"birthday"];
    } else if ([key isEqualToString:@"pl-usr-gender"]) {
        [self setValue:value forKey:@"gender"];
    } else if ([key isEqualToString:@"pl-usr-points"]) {
        [self setValue:value forKey:@"points"];
    } else if ([key isEqualToString:@"pl-usr-achv_unlocked"]) {
        [self setValue:value forKey:@"unlockedAchievements"];
    } else if ([key isEqualToString:@"pl-usr-follower_cnt"]) {
        [self setValue:value forKey:@"followerCount"];
    } else if ([key isEqualToString:@"pl-usr-following_cnt"]) {
        [self setValue:value forKey:@"followingCount"];
    } else if ([key isEqualToString:@"pl-usr-img"]) {
        [self setValue:value forKey:@"avatarUrl"];
    } else if ([key isEqualToString:@"pl-usr-followed"]) {
        followed = [(NSNumber *)value boolValue];
    } else if ([key isEqualToString:@"pl-usr-following"]) {
        following = [(NSNumber *)value boolValue];
    }
}

- (NSDictionary *) getDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (Class) {
        [dict setObject:Class forKey:@"pl-class"];
    }
    if (Id) {
        [dict setObject:Id forKey:@"pl-id"];
    }
    if (version) {
        [dict setObject:version forKey:@"pl-version"];
    }
    if (createdBy) {
        [dict setObject:[createdBy getDictionary] forKey:@"pl-created-by"];
    }
    if (createdTime) {
        [dict setObject:createdTime forKey:@"pl-created-time"];
    }
    if (updatedBy) {
        [dict setObject:[updatedBy getDictionary] forKey:@"pl-upd-by"];
    }
    if (updatedTime) {
        [dict setObject:updatedTime forKey:@"pl-upd-time"];
    }
    
    if (nickname) {
        [dict setObject:nickname forKey:@"pl-usr-nickname"];
    }
    if (firstName) {
        [dict setObject:firstName forKey:@"pl-usr-fname"];
    }
    if (lastName) {
        [dict setObject:lastName forKey:@"pl-usr-lname"];
    }
    if (email) {
        [dict setObject:email forKey:@"pl-usr-email"];
    }
    if (birthday) {
        [dict setObject:birthday forKey:@"pl-usr-bday"];
    }
    if (gender) {
        [dict setObject:gender forKey:@"pl-usr-gender"];
    }
    if (points) {
        [dict setObject:points forKey:@"pl-usr-points"];
    }
    if (unlockedAchievements) {
        [dict setObject:unlockedAchievements forKey:@"pl-usr-achv_unlocked"];
    }
    if (followerCount) {
        [dict setObject:followerCount forKey:@"pl-usr-follower_cnt"];
    }

    if (followingCount) {
        [dict setObject:followingCount forKey:@"pl-usr-following_cnt"];
    }

    if (avatarUrl) {
        [dict setObject:avatarUrl forKey:@"pl-usr-img"];
    }
    
    if(following){
        [dict setObject:[NSNumber numberWithBool:following] forKey:@"pl-usr-following"];
    }
    
    if(followed){
        [dict setObject:[NSNumber numberWithBool:followed] forKey:@"pl-usr-followed"];
    }
    
    return dict;
}
@end
