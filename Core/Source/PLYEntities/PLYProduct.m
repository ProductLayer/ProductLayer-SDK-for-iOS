//
//  PLYProduct.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYProduct.h"
#import "PLYImage.h"
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
		[self setValue:value forKey:@"GTIN"];
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
	else if ([key isEqualToString:@"pl-prod-img"])
	{
		_defaultImage = [[PLYImage alloc] initWithDictionary:value];
	}
	else if ([key isEqualToString:@"pl-prod-pkg"])
	{
		[self setValue:value forKey:@"packaging"];
	}
	else if ([key isEqualToString:@"pl-prod-review-rating"])
	{
		[self setValue:value forKey:@"averageReviewRating"];
	}
	else if ([key isEqualToString:@"pl-prod-review-count"])
	{
		[self setValue:value forKey:@"numberOfReviews"];
	}
    else if ([key isEqualToString:@"pl-prod-opine-count"])
    {
        [self setValue:value forKey:@"numberOfOpines"];
    }
    else if ([key isEqualToString:@"pl-prod-img-count"])
    {
        [self setValue:value forKey:@"numberOfImages"];
    }
    else if ([key isEqualToString:@"pl-prod-char"])
	{
		[self setValue:value forKey:@"characteristics"];
	}
	else if ([key isEqualToString:@"pl-prod-nutr"])
	{
		[self setValue:value forKey:@"nutritious"];
	}
	else if ([key isEqualToString:@"pl-additional-lng"])
	{
		self.additionalLanguages = value;
	}
	else if ([key isEqualToString:@"pl-prod-lnks-buy"])
	{
		[self setValue:value forKey:@"buyLinks"];
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
		dict[@"pl-prod-desc-long"] = _longDescription;
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
	
	if (_defaultImage)
	{
		dict[@"pl-prod-img"] = [_defaultImage dictionaryRepresentation];
	}
	
	if (_packaging)
	{
		dict[@"pl-prod-pkg"] = [_packaging dictionaryRepresentation];
	}
	
	dict[@"pl-prod-review-rating"] = @(_averageReviewRating);
	dict[@"pl-prod-review-count"] = @(_numberOfReviews);
    dict[@"pl-prod-opine-count"] = @(_numberOfOpines);
    dict[@"pl-prod-img-count"] = @(_numberOfImages);
	
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
	
	if (_additionalLanguages)
	{
		dict[@"pl-additional-lng"] = _additionalLanguages;
	}
	
	if (_buyLinks)
	{
		dict[@"pl-prod-lnks-buy"] = _buyLinks;
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYProduct *)entity
{
	[super updateFromEntity:entity];
	
	self.brandName = entity.brandName;
	self.brandOwner = entity.brandOwner;
	self.language = entity.language;
	self.category = entity.category;
	self.longDescription = entity.longDescription;
	self.shortDescription = entity.shortDescription;
	self.GTIN = entity.GTIN;
	self.homepage = entity.homepage;
	self.links = entity.links;
	self.name = entity.name;
	self.packaging = entity.packaging;
	self.averageReviewRating = entity.averageReviewRating;
	self.numberOfReviews = entity.numberOfReviews;
    self.numberOfOpines = entity.numberOfOpines;
    self.numberOfImages = entity.numberOfImages;
	self.characteristics = entity.characteristics;
	self.nutritious = entity.nutritious;
	self.sourceURL = entity.sourceURL;
	self.defaultImage = entity.defaultImage;
	self.additionalLanguages = entity.additionalLanguages;
	self.buyLinks = entity.buyLinks;
}

@end
