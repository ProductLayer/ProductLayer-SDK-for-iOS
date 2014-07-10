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
	if ([key isEqualToString:@"pl-usr-nickname"])
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
	else if ([key isEqualToString:@"pl-usr-achvself.unlocked"])
	{
		[self setValue:value forKey:@"unlockedAchievements"];
	}
	else if ([key isEqualToString:@"pl-usr-followerself.cnt"])
	{
		[self setValue:value forKey:@"followerCount"];
	}
	else if ([key isEqualToString:@"pl-usr-followingself.cnt"])
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
	else
	{
		[super setValue:value forUndefinedKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (self.nickname)
	{
		[dict setObject:self.nickname forKey:@"pl-usr-nickname"];
	}
	
	if (self.firstName)
	{
		[dict setObject:self.firstName forKey:@"pl-usr-fname"];
	}
	
	if (self.lastName)
	{
		[dict setObject:self.lastName forKey:@"pl-usr-lname"];
	}
	
	if (self.email)
	{
		[dict setObject:self.email forKey:@"pl-usr-email"];
	}
	
	if (self.birthday)
	{
		[dict setObject:self.birthday forKey:@"pl-usr-bday"];
	}
	
	if (self.gender)
	{
		[dict setObject:self.gender forKey:@"pl-usr-gender"];
	}
	
	if (self.points)
	{
		[dict setObject:self.points forKey:@"pl-usr-points"];
	}
	
	if (self.unlockedAchievements)
	{
		[dict setObject:self.unlockedAchievements forKey:@"pl-usr-achvself.unlocked"];
	}
	
	if (self.followerCount)
	{
		[dict setObject:self.followerCount forKey:@"pl-usr-followerself.cnt"];
	}
	
	if (self.followingCount)
	{
		[dict setObject:self.followingCount forKey:@"pl-usr-followingself.cnt"];
	}
	
	if (self.avatarUrl)
	{
		[dict setObject:self.avatarUrl forKey:@"pl-usr-img"];
	}
	
	if (self.following)
	{
		[dict setObject:[NSNumber numberWithBool:self.following] forKey:@"pl-usr-following"];
	}
	
	if (self.followed)
	{
		[dict setObject:[NSNumber numberWithBool:self.followed] forKey:@"pl-usr-followed"];
	}
	
	// return immutable
	return [dict copy];
}
@end
