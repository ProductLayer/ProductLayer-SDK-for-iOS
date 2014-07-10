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

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.User";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-created-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.createdBy = [[PLYAuditor alloc] initWithDictionary:value];
		}
	}
	else if ([key isEqualToString:@"pl-app"] || [key isEqualToString:@"pl-usr-roles"])
	{
		// Do nothing
	}
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.updatedBy = [[PLYAuditor alloc] initWithDictionary:value];
		}
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-class"])
	{
		[self setValue:value forKey:@"Class"];
	}
	else if ([key isEqualToString:@"pl-id"])
	{
		[self setValue:value forKey:@"Id"];
	}
	else if ([key isEqualToString:@"pl-version"])
	{
		[self setValue:value forKey:@"version"];
	}
	else if ([key isEqualToString:@"pl-created-by"])
	{
		[self setValue:value forKey:@"createdBy"];
	}
	else if ([key isEqualToString:@"pl-created-time"])
	{
		[self setValue:value forKey:@"createdTime"];
	}
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		[self setValue:value forKey:@"updatedBy"];
	}
	else if ([key isEqualToString:@"pl-upd-time"])
	{
		[self setValue:value forKey:@"updatedTime"];
	}
	else if ([key isEqualToString:@"pl-usr-nickname"])
	{
		[self setValue:value forKey:@"nickname"];
	}
	else if ([key isEqualToString:@"pl-usr-fname"])
	{
		[self setValue:value forKey:@"firstName"];
	}
	else if ([key isEqualToString:@"pl-usr-lname"])
	{
		[self setValue:value forKey:@"lastName"];
	}
	else if ([key isEqualToString:@"pl-usr-email"])
	{
		[self setValue:value forKey:@"email"];
	}
	else if ([key isEqualToString:@"pl-usr-bday"])
	{
		[self setValue:value forKey:@"birthday"];
	}
	else if ([key isEqualToString:@"pl-usr-gender"])
	{
		[self setValue:value forKey:@"gender"];
	}
	else if ([key isEqualToString:@"pl-usr-points"])
	{
		[self setValue:value forKey:@"points"];
	}
	else if ([key isEqualToString:@"pl-usr-achv_unlocked"])
	{
		[self setValue:value forKey:@"unlockedAchievements"];
	}
	else if ([key isEqualToString:@"pl-usr-follower_cnt"])
	{
		[self setValue:value forKey:@"followerCount"];
	}
	else if ([key isEqualToString:@"pl-usr-following_cnt"])
	{
		[self setValue:value forKey:@"followingCount"];
	}
	else if ([key isEqualToString:@"pl-usr-img"])
	{
		[self setValue:value forKey:@"avatarUrl"];
	}
	else if ([key isEqualToString:@"pl-usr-followed"])
	{
		self.followed = [(NSNumber *)value boolValue];
	}
	else if ([key isEqualToString:@"pl-usr-following"])
	{
		self.following = [(NSNumber *)value boolValue];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (_Class)
	{
		[dict setObject:_Class forKey:@"pl-class"];
	}
	
	if (_Id)
	{
		[dict setObject:_Id forKey:@"pl-id"];
	}
	
	if (_version)
	{
		[dict setObject:_version forKey:@"pl-version"];
	}
	
	if (_createdBy)
	{
		[dict setObject:[_createdBy dictionaryRepresentation] forKey:@"pl-created-by"];
	}
	
	if (_createdTime)
	{
		[dict setObject:_createdTime forKey:@"pl-created-time"];
	}
	
	if (_updatedBy)
	{
		[dict setObject:[_updatedBy dictionaryRepresentation] forKey:@"pl-upd-by"];
	}
	
	if (_updatedTime)
	{
		[dict setObject:_updatedTime forKey:@"pl-upd-time"];
	}
	
	if (_nickname)
	{
		[dict setObject:_nickname forKey:@"pl-usr-nickname"];
	}
	
	if (_firstName)
	{
		[dict setObject:_firstName forKey:@"pl-usr-fname"];
	}
	
	if (_lastName)
	{
		[dict setObject:_lastName forKey:@"pl-usr-lname"];
	}
	
	if (_email)
	{
		[dict setObject:_email forKey:@"pl-usr-email"];
	}
	
	if (_birthday)
	{
		[dict setObject:_birthday forKey:@"pl-usr-bday"];
	}
	
	if (_gender)
	{
		[dict setObject:_gender forKey:@"pl-usr-gender"];
	}
	
	if (_points)
	{
		[dict setObject:_points forKey:@"pl-usr-points"];
	}
	
	if (_unlockedAchievements)
	{
		[dict setObject:_unlockedAchievements forKey:@"pl-usr-achv_unlocked"];
	}
	
	if (_followerCount)
	{
		[dict setObject:_followerCount forKey:@"pl-usr-follower_cnt"];
	}
	
	if (_followingCount)
	{
		[dict setObject:_followingCount forKey:@"pl-usr-following_cnt"];
	}
	
	if (_avatarUrl)
	{
		[dict setObject:_avatarUrl forKey:@"pl-usr-img"];
	}
	
	if (_following)
	{
		[dict setObject:[NSNumber numberWithBool:_following] forKey:@"pl-usr-following"];
	}
	
	if (_followed)
	{
		[dict setObject:[NSNumber numberWithBool:_followed] forKey:@"pl-usr-followed"];
	}
	
	return dict;
}
@end
