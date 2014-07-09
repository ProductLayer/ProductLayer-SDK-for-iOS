//
//  PLYProduct.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYProduct.h"

#import "PLYAuditor.h"
#import "PLYPackaging.h"
#import "DTLog.h"

@implementation PLYProduct

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Product";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-created-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.createdBy = [[PLYAuditor alloc] initWithDictionary:value];
		}
		
	}
	else if ([key isEqualToString:@"pl-prod-lnks"])
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
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.updatedBy = [[PLYAuditor alloc] initWithDictionary:value];
		}
	}
	else
	{
		[super setValue:value forKey:key];
	}
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-class"])
	{
		[self setValue:value forKey:@"Class"];
	}
	else if ([key isEqualToString:@"pl-id"])
	{
		[self setValue:value forKey:@"Id"];
	}
	else if ([key isEqualToString:@"pl-brand-name"])
	{
		[self setValue:value forKey:@"brandName"];
	}
	else if ([key isEqualToString:@"pl-brand-own-name"])
	{
		[self setValue:value forKey:@"brandOwner"];
	}
	else if ([key isEqualToString:@"pl-created-by"])
	{
		[self setValue:value forKey:@"createdBy"];
	}
	else if ([key isEqualToString:@"pl-created-time"])
	{
		[self setValue:value forKey:@"createdTime"];
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
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		[self setValue:value forKey:@"updatedBy"];
	}
	else if ([key isEqualToString:@"pl-upd-time"])
	{
		[self setValue:value forKey:@"updatedTime"];
	}
	else if ([key isEqualToString:@"pl-prod-char"])
	{
		[self setValue:value forKey:@"characteristics"];
	}
	else if ([key isEqualToString:@"pl-prod-nutr"])
	{
		[self setValue:value forKey:@"nutritious"];
	}
	else if ([key isEqualToString:@"pl-version"])
	{
		[self setValue:value forKey:@"version"];
	}
}

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if (_Class)
	{
		[dict setObject:_Class forKey:@"pl-class"];
	}
	
	if (_Id)
	{
		[dict setObject:_Id forKey:@"pl-id"];
	}
	
	if (_brandName)
	{
		[dict setObject:_brandName forKey:@"pl-brand-name"];
	}
	
	if (_brandOwner)
	{
		[dict setObject:_brandOwner forKey:@"pl-brand-own-name"];
	}
	
	if (_createdBy)
	{
		[dict setObject:[_createdBy dictionaryRepresentation] forKey:@"pl-created-by"];
	}
	
	if (_createdTime)
	{
		[dict setObject:_createdTime forKey:@"pl-created-time"];
	}
	
	if (_language)
	{
		[dict setObject:_language forKey:@"pl-lng"];
	}
	
	if (_category)
	{
		[dict setObject:_category forKey:@"pl-prod-cat"];
	}
	
	if (_longDescription)
	{
		[dict setObject:_longDescription forKey:@"pl-prod-desc-long"];
	}
	
	if (_shortDescription)
	{
		[dict setObject:_shortDescription forKey:@"pl-prod-desc-short"];
	}
	
	if (_gtin)
	{
		[dict setObject:_gtin forKey:@"pl-prod-gtin"];
	}
	
	if (_homepage)
	{
		[dict setObject:_homepage forKey:@"pl-prod-homepage"];
	}
	
	if (_links)
	{
		[dict setObject:_links forKey:@"pl-prod-lnks"];
	}
	
	if (_name)
	{
		[dict setObject:_name forKey:@"pl-prod-name"];
	}
	
	if (_packaging)
	{
		[dict setObject:[_packaging dictionaryRepresentation] forKey:@"pl-prod-pkg"];
	}
	
	if (_rating)
	{
		[dict setObject:_rating forKey:@"pl-prod-rating"];
	}
	
	if (_updatedBy)
	{
		[dict setObject:[_updatedBy dictionaryRepresentation] forKey:@"pl-upd-by"];
	}
	
	if (_updatedTime)
	{
		[dict setObject:_updatedTime forKey:@"pl-upd-time"];
	}
	
	if (_characteristics)
	{
		[dict setObject:_characteristics forKey:@"pl-prod-char"];
	}
	
	if (_nutritious)
	{
		[dict setObject:_nutritious forKey:@"pl-prod-nutr"];
	}
	
	if (_version)
	{
		[dict setObject:_version forKey:@"pl-version"];
	}
	
	return dict;
}



@end
