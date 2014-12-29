//
//  PLYBrandOwner.m
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYBrandOwner.h"
#import "PLYBrand.h"

@implementation PLYBrandOwner

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.BrandOwner";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-brand-own-name"])
	{
		self.name = value;
	}
	else if ([key isEqualToString:@"pl-brands"])
	{
		if ([value isKindOfClass:[NSArray class]])
		{
			NSDictionary *dict = (NSDictionary *)value;
			NSMutableArray *tmpArray = [NSMutableArray array];
			
			for (NSDictionary *oneValue in dict)
			{
				PLYBrand *brand = [[PLYBrand alloc] initWithDictionary:oneValue];
				[tmpArray addObject:brand];
			}
			
			self.brands = tmpArray;
		}
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
		dict[@"pl-brand-own-name"] = _name;
	}
	
	if ([_brands count])
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		for (PLYBrand *brand in _brands)
		{
			[tmpArray addObject:[brand dictionaryRepresentation]];
		}
		
		dict[@"pl-brands"] = tmpArray;
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYBrandOwner *)entity
{
	[super updateFromEntity:entity];
	
	self.name = entity.name;
	self.brands = entity.brands;
}

@end
