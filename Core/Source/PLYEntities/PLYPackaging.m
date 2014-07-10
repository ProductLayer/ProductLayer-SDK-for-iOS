//
//  PLYPackaging.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYPackaging.h"

@implementation PLYPackaging

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-prod-pkg-cont"])
	{
		[self setValue:value forKey:@"contains"];
	}
	else if ([key isEqualToString:@"pl-prod-pkg-name"])
	{
		[self setValue:value forKey:@"name"];
	}
	else if ([key isEqualToString:@"pl-prod-pkg-desc"])
	{
		[self setValue:value forKey:@"description"];
	}
	else if ([key isEqualToString:@"pl-prod-pkg-units"])
	{
		[self setValue:value forKey:@"unit"];
	}
	else
	{
		[super setValue:value forUndefinedKey:key];
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
	
	if (_description)
	{
		[dict setObject:_description forKey:@"pl-prod-pkg-desc"];
	}
	
	if (_unit)
	{
		[dict setObject:_unit forKey:@"pl-prod-pkg-units"];
	}
	
	// return immutable
	return [dict copy];
}

@end
