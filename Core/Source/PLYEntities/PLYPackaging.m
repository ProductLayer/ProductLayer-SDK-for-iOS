//
//  PLYPackaging.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYPackaging.h"

@implementation PLYPackaging

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-prod-pkg-cont"])
	{
		self.contains = value;
	}
	else if ([key isEqualToString:@"pl-prod-pkg-name"])
	{
		self.name = value;
	}
	else if ([key isEqualToString:@"pl-prod-pkg-desc"])
	{
		self.descriptionText = value;
	}
	else if ([key isEqualToString:@"pl-prod-pkg-units"])
	{
		[self setValue:value forKey:@"units"];
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_contains)
	{
		dict[@"pl-prod-pkg-cont"] = _contains;
	}
	
	if (_name)
	{
		dict[@"pl-prod-pkg-name"] = _name;
	}
	
	if (_descriptionText)
	{
		dict[@"pl-prod-pkg-desc"] = _descriptionText;
	}
	
	if (_units)
	{
		dict[@"pl-prod-pkg-units"] = @(_units);
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYPackaging *)entity
{
	[super updateFromEntity:entity];
	
	self.contains = entity.contains;
	self.name = entity.name;
	self.descriptionText = entity.descriptionText;
	self.units = entity.units;
}

@end
