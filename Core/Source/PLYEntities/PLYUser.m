//
//  PLYUser.m
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYUser.h"
#import "PLYUserAvatar.h"


@interface PLYUser ()

// private property, set if user has an avatar
@property (nonatomic, copy) NSString *avatarImageIdentifier;

// all read-only properties are settable internally

@property (nonatomic, assign, readwrite) NSInteger points;
@property (nonatomic, copy, readwrite) NSArray *unlockedAchievements;
@property (nonatomic, assign, readwrite) NSUInteger followerCount;
@property (nonatomic, assign, readwrite) NSUInteger followingCount;
@property (nonatomic, copy, readwrite) NSURL *avatarURL;
@property (nonatomic, assign, readwrite) BOOL following;
@property (nonatomic, assign, readwrite) BOOL followed;
@property (nonatomic, copy, readwrite) NSDictionary *socialConnections;

@end

@implementation PLYUser

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
		[self setValue:value forKey:@"avatarImageIdentifier"];
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
		dict[@"pl-usr-fname"] = _firstName;
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
		dict[@"pl-usr-follower_cnt"] = @(_followerCount);
	}
	
	if (_followingCount)
	{
		dict[@"pl-usr-following_cnt"] = @(_followingCount);
	}
	
	if (_avatarURL)
	{
		dict[@"pl-usr-img"] = [_avatarURL absoluteString];
	}
	
	if (_avatarImageIdentifier)
	{
		dict[@"pl-usr-img_id"] = _avatarImageIdentifier;
	}
	
	if (_following)
	{
		dict[@"pl-usr-following"] = @(_following);
	}
	
	if (_followed)
	{
		dict[@"pl-usr-followed"] = @(_followed);
	}
	
	if (_socialConnections)
	{
		dict[@"pl-usr-social-connections"] = _socialConnections;
	}
	
	// return immutable
	return [dict copy];
}

- (PLYUserAvatar *)avatar
{
	PLYUserAvatar *avatar = [PLYUserAvatar new];
	[avatar setValue:self.nickname forKey:@"userNickname"];
	[avatar setValue:self.Id forKey:@"userID"];

	if (_avatarImageIdentifier)
	{
		[avatar setValue:_avatarImageIdentifier forKey:@"fileId"];
	}
	
	if (_avatarURL)
	{
		[avatar setValue:_avatarURL forKey:@"imageURL"];
	}
	
	return avatar;
}

- (void)updateFromEntity:(PLYUser *)entity
{
	[super updateFromEntity:entity];
	
	self.nickname = entity.nickname;
	self.firstName = entity.firstName;
	self.lastName = entity.lastName;
	self.email = entity.email;
	self.birthday = entity.birthday;
	self.gender = entity.gender;
	self.points = entity.points;
	self.unlockedAchievements = entity.unlockedAchievements;
	self.followerCount = entity.followerCount;
	self.followingCount = entity.followingCount;
	self.avatarURL = entity.avatarURL;
	self.following = entity.following;
	self.followed = entity.followed;
	self.socialConnections = entity.socialConnections;
}

@end
