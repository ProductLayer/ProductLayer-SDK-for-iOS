//
//  PLYProduct.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYProduct.h"

#import "PLYUser.h"
#import "PLYPackaging.h"

@implementation PLYProduct

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Product";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-prod-lnks"])
	{
		if ([value isKindOfClass:[NSArray class]])
		{
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			
			for (id valueMember in value)
			{
				[myMembers addObject:valueMember];
			}
			
			self.links = myMembers;
		}
	}
	else if ([key isEqualToString:@"pl-prod-pkg"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.packaging = [[PLYPackaging alloc] initWithDictionary:value];
		}
	}
	else if ([key isEqualToString:@"pl-prod-src"])
	{
		self.sourceURL = [NSURL URLWithString:value];
	}
	else if ([key isEqualToString:@"pl-brand-name"])
	{
		[self setValue:value forKey:@"brandName"];
	}
	else if ([key isEqualToString:@"pl-brand-own-name"])
	{
		[self setValue:value forKey:@"brandOwner"];
	}
	else if ([key isEqualToString:@"pl-lng"])
	{
		[self setValue:value forKey:@"language"];
	}
	else if ([key isEqualToString:@"pl-prod-cat"])
	{
		[self setValue:value forKey:@"category"];
	}
	else if ([key isEqualToString:@"pl-prod-desc-long"])
	{
		[self setValue:value forKey:@"longDescription"];
	}
	else if ([key isEqualToString:@"pl-prod-desc-short"])
	{
		[self setValue:value forKey:@"shortDescription"];
	}
	else if ([key isEqualToString:@"pl-prod-gtin"])
	{
		[self setValue:value forKey:@"gtin"];
	}
	else if ([key isEqualToString:@"pl-prod-homepage"])
	{
		[self setValue:value forKey:@"homepage"];
	}
	else if ([key isEqualToString:@"pl-prod-lnks"])
	{
		[self setValue:value forKey:@"links"];
	}
	else if ([key isEqualToString:@"pl-prod-name"])
	{
		[self setValue:value forKey:@"name"];
	}
	else if ([key isEqualToString:@"pl-prod-pkg"])
	{
		[self setValue:value forKey:@"packaging"];
	}
	else if ([key isEqualToString:@"pl-prod-rating"])
	{
		[self setValue:value forKey:@"rating"];
	}
	else if ([key isEqualToString:@"pl-prod-char"])
	{
		[self setValue:value forKey:@"characteristics"];
	}
	else if ([key isEqualToString:@"pl-prod-nutr"])
	{
		[self setValue:value forKey:@"nutritious"];
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_brandName)
	{
		dict[@"pl-brand-name"] = _brandName;
	}
	
	if (_brandOwner)
	{
		dict[@"pl-brand-own-name"] = _brandOwner;
	}
	
	if (_language)
	{
		dict[@"pl-lng"] = _language;
	}
	
	if (_category)
	{
		dict[@"pl-prod-cat"] = _category;
	}
	
	if (_longDescription)
	{
		dict[@"pl-prod-desc-lon"] = _longDescription;
	}
	
	if (_shortDescription)
	{
		dict[@"pl-prod-desc-short"] = _shortDescription;
	}
	
	if (_GTIN)
	{
		dict[@"pl-prod-gtin"] = _GTIN;
	}
	
	if (_homepage)
	{
		dict[@"pl-prod-homepage"] = _homepage;
	}
	
	if (_links)
	{
		dict[@"pl-prod-lnks"] = _links;
	}
	
	if (_name)
	{
		dict[@"pl-prod-name"] = _name;
	}
	
	if (_packaging)
	{
		dict[@"pl-prod-pkg"] = [_packaging dictionaryRepresentation];
	}
	
	if (_rating)
	{
		dict[@"pl-prod-rating"] = _rating;
	}
	
	if (_characteristics)
	{
		dict[@"pl-prod-char"] = _characteristics;
	}
	
	if (_nutritious)
	{
		dict[@"pl-prod-nutr"] = _nutritious;
	}
	
	if (_sourceURL)
	{
		dict[@"pl-prod-src"] = [self.sourceURL absoluteString];
	}
	
	// return immutable
	return [dict copy];
}

@end
