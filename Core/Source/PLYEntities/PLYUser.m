//
//  PLYUser.m
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYUser.h"

#import "PLYUser.h"

@implementation PLYUser
{
	NSString *_avatarImageIdentifier;
}

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.User";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-app"] || [key isEqualToString:@"pl-usr-roles"])
	{
		// Do nothing
	}
	else if ([key isEqualToString:@"pl-usr-nickname"])
	{
		self.nickname = value;
	}
	else if ([key isEqualToString:@"pl-usr-fname"])
	{
		self.firstName = value;
	}
	else if ([key isEqualToString:@"pl-usr-lname"])
	{
		self.lastName = value;
	}
	else if ([key isEqualToString:@"pl-usr-email"])
	{
		self.email = value;
	}
	else if ([key isEqualToString:@"pl-usr-bday"])
	{
		self.birthday = value;
	}
	else if ([key isEqualToString:@"pl-usr-gender"])
	{
		self.gender = value;
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
		_avatarURL = [NSURL URLWithString:value];
	}
	else if ([key isEqualToString:@"pl-usr-followed"])
	{
		[self setValue:value forKey:@"followed"];
	}
	else if ([key isEqualToString:@"pl-usr-following"])
	{
		[self setValue:value forKey:@"following"];
	}
	else if ([key isEqualToString:@"pl-usr-img_id"])
	{
		// ignored
	}
	else if ([key isEqualToString:@"pl-usr-social-connections"])
	{
		[self setValue:value forKey:@"socialConnections"];
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_nickname)
	{
		dict[@"pl-usr-nickname"] = _nickname;
	}
	
	if (_firstName)
	{
		dict[@"pl-usr-fname"] = _nickname;
	}
	
	if (_lastName)
	{
		dict[@"pl-usr-lname"] = _lastName;
	}
	
	if (_email)
	{
		dict[@"pl-usr-email"] = _email;
	}
	
	if (_birthday)
	{
		dict[@"pl-usr-bday"] = _birthday;
	}
	
	if (_gender)
	{
		dict[@"pl-usr-gender"] = _gender;
	}
	
	if (_points)
	{
		dict[@"pl-usr-points"] = @(_points);
	}
	
	if (_unlockedAchievements)
	{
		dict[@"pl-usr-achv_unlocked"] = _unlockedAchievements;
	}
	
	if (_followerCount)
	{
		dict[@"pl-usr-follower_cnt"] = _followerCount;
	}
	
	if (_followingCount)
	{
		dict[@"pl-usr-following_cnt"] = _followingCount;
	}
	
	if (_avatarURL)
	{
		dict[@"pl-usr-img"] = [_avatarURL absoluteString];
	}
	
	if (_following)
	{
		dict[@"pl-usr-following"] = [NSNumber numberWithBool:_following];
	}
	
	if (_followed)
	{
		dict[@"pl-usr-followed"] = [NSNumber numberWithBool:_followed];
	}
	
	if (_socialConnections)
	{
		dict[@"pl-usr-social-connections"] = _socialConnections;
	}
	
	// return immutable
	return [dict copy];
}
@end
