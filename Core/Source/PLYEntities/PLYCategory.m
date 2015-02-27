//
//  PLYCategory.m
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYCategory.h"

@implementation PLYCategory

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Category";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-cat-key"])
	{
		[self setValue:value forKey:@"key"];
	}
	else if ([key isEqualToString:@"pl-cat-def_name"])
	{
		[self setValue:value forKey:@"localizedName"];
	}
	else if ([key isEqualToString:@"pl-cat-subcat"])
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		for (NSDictionary *dict in value)
		{
			PLYCategory *subCategory = [[PLYCategory alloc] initWithDictionary:dict];
			[tmpArray addObject:subCategory];
		}
		
		_subCategories = [tmpArray copy];
	}
	else if ([key isEqualToString:@"pl-cat-prod_cnt"])
	{
		// ignore
	}
	else if ([key isEqualToString:@"pl-cat-def_char"])
	{
		// ignore
	}
	else if ([key isEqualToString:@"pl-cat-def_desc"])
	{
		// ignore
	}
	else if ([key isEqualToString:@"pl-cat-def_nutr"])
	{
		// ignore
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_key)
	{
		dict[@"pl-cat-key"] = _key;
	}
	
	if (_localizedName)
	{
		dict[@"pl-cat-def_name"] = _localizedName;
	}
	
	if (_subCategories)
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		for (PLYCategory *subCategory in _subCategories)
		{
			NSDictionary *dict = [subCategory dictionaryRepresentation];
			[tmpArray addObject:dict];
		}
		
		dict[@"pl-cat-subcat"] = [tmpArray copy];
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYCategory *)entity
{
	[super updateFromEntity:entity];
	
	_key = [entity.key copy];
	_localizedName = [entity.localizedName copy];
	_subCategories = [entity.subCategories copy];
}

@end
