//
//  PLYUserAvatar.m
//  PL
//
//  Created by Oliver Drobnik on 28/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYUserAvatar.h"

@implementation PLYUserAvatar


+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Avatar";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-usr-id"])
	{
		self.userID = value;
	}
	else if ([key isEqualToString:@"pl-usr-nickname"])
	{
		self.userNickname = value;
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_userID)
	{
		dict[@"pl-usr-id"] = _userID;
	}
	
	if (_userNickname)
	{
		dict[@"pl-usr-nickname"] = _userNickname;
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYUserAvatar *)entity
{
	[super updateFromEntity:entity];
	
	self.userID = entity.userID;
	self.userNickname = entity.userNickname;
}

- (BOOL)canBeVoted
{
	return NO;
}

@end
