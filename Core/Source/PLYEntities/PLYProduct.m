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
	
	if (self.brandName)
	{
		[dict setObject:self.brandName forKey:@"pl-brand-name"];
	}
	
	if (self.brandOwner)
	{
		[dict setObject:self.brandOwner forKey:@"pl-brand-own-name"];
	}
	
	if (self.language)
	{
		[dict setObject:self.language forKey:@"pl-lng"];
	}
	
	if (self.category)
	{
		[dict setObject:self.category forKey:@"pl-prod-cat"];
	}
	
	if (self.longDescription)
	{
		[dict setObject:self.longDescription forKey:@"pl-prod-desc-long"];
	}
	
	if (self.shortDescription)
	{
		[dict setObject:self.shortDescription forKey:@"pl-prod-desc-short"];
	}
	
	if (self.gtin)
	{
		[dict setObject:self.gtin forKey:@"pl-prod-gtin"];
	}
	
	if (self.homepage)
	{
		[dict setObject:self.homepage forKey:@"pl-prod-homepage"];
	}
	
	if (self.links)
	{
		[dict setObject:self.links forKey:@"pl-prod-lnks"];
	}
	
	if (self.name)
	{
		[dict setObject:self.name forKey:@"pl-prod-name"];
	}
	
	if (self.packaging)
	{
		[dict setObject:[self.packaging dictionaryRepresentation] forKey:@"pl-prod-pkg"];
	}
	
	if (self.rating)
	{
		[dict setObject:self.rating forKey:@"pl-prod-rating"];
	}
	
	if (self.characteristics)
	{
		[dict setObject:self.characteristics forKey:@"pl-prod-char"];
	}
	
	if (self.nutritious)
	{
		[dict setObject:self.nutritious forKey:@"pl-prod-nutr"];
	}
	
	if (self.sourceURL)
	{
		[dict setObject:[self.sourceURL absoluteString] forKey:@"pl-prod-src"];
	}
	
	// return immutable
	return [dict copy];
}

@end
