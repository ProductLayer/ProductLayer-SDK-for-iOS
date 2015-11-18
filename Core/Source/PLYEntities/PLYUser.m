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

// all read-only properties are settable internally

@property (nonatomic, assign, readwrite) NSInteger points;
@property (nonatomic, assign, readwrite) NSInteger level;
@property (nonatomic, assign, readwrite) NSInteger progress;


@property (nonatomic, copy, readwrite) NSArray *unlockedAchievements;
@property (nonatomic, assign, readwrite) NSUInteger followerCount;
@property (nonatomic, assign, readwrite) NSUInteger followingCount;
@property (nonatomic, assign, readwrite) BOOL following;
@property (nonatomic, assign, readwrite) BOOL followed;
@property (nonatomic, copy, readwrite) NSDictionary *socialConnections;
@property (nonatomic, copy, readwrite) NSArray *roles;
@property (nonatomic, copy, readwrite) PLYUserAvatar *avatar;
@property (nonatomic, copy, readwrite) NSDictionary *settings;

@end

@implementation PLYUser

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.User";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-app"])
	{
		// Do nothing
	}
	else if ([key isEqualToString:@"pl-usr-roles"])
	{
		self.roles = value;
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
    else if ([key isEqualToString:@"pl-usr-level"])
    {
        [self setValue:value forKey:@"level"];
    }
    else if ([key isEqualToString:@"pl-usr-progress"])
    {
        [self setValue:value forKey:@"progress"];
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
		// ignore
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
		// ignore
	}
	else if ([key isEqualToString:@"pl-usr-social-connections"])
	{
		[self setValue:value forKey:@"socialConnections"];
	}
	else if ([key isEqualToString:@"pl-usr-avatar"])
	{
		_avatar = [[PLYUserAvatar alloc] initWithDictionary:value];
	}
    else if ([key isEqualToString:@"pl-usr-settings"])
    {
        [self setValue:value forKey:@"settings"];
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
    
    if (_level)
    {
        dict[@"pl-usr-level"] = @(_level);
    }

    if (_progress)
    {
        dict[@"pl-usr-progress"] = @(_progress);
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
	
	if (_avatar)
	{
		dict[@"pl-usr-avatar"] = [_avatar dictionaryRepresentation];
	}
	
	if (_roles)
	{
		dict[@"pl-usr-roles"] = _roles;
	}
    
    if (_settings)
    {
        dict[@"pl-usr-settings"] = _settings;
    }
	
	// return immutable
	return [dict copy];
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
    self.level = entity.level;
    self.progress = entity.progress;
	self.unlockedAchievements = entity.unlockedAchievements;
	self.followerCount = entity.followerCount;
	self.followingCount = entity.followingCount;
	self.following = entity.following;
	self.followed = entity.followed;
	self.socialConnections = entity.socialConnections;
	self.roles = entity.roles;
	
	if (entity.avatar)
	{
		self.avatar = entity.avatar;
	}
    
    self.settings = entity.settings;
}

@end
