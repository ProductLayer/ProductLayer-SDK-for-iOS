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
		self.unit = value;
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
		[dict setObject:_contains forKey:@"pl-prod-pkg-cont"];
	}
	
	if (_name)
	{
		[dict setObject:_name forKey:@"pl-prod-pkg-name"];
	}
	
	if (_descriptionText)
	{
		[dict setObject:_descriptionText forKey:@"pl-prod-pkg-desc"];
	}
	
	if (_unit)
	{
		[dict setObject:_unit forKey:@"pl-prod-pkg-units"];
	}
	
	// return immutable
	return [dict copy];
}

@end
