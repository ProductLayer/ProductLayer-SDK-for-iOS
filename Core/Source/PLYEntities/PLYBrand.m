//
//  PLYBrand.m
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYBrand.h"

@implementation PLYBrand

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Brand";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-brand-name"])
	{
		self.name = value;
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_name)
	{
		dict[@"pl-brand-name"] = _name;
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYBrand *)entity
{
	[super updateFromEntity:entity];
	
	self.name = entity.name;
}

@end
