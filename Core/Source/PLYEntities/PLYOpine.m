//
//  PLYOpine.m
//  PL
//
//  Created by Oliver Drobnik on 29/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYOpine.h"
#import "PLYImage.h"
#import "PLYUploadImage.h"
#import "PLYProduct.h"

@interface PLYOpine ()

// read-only properties are writable internally

@property (nonatomic, copy, readwrite) NSString *twitterPostIdentifier;
@property (nonatomic, copy, readwrite) NSString *facebookPostIdentifier;

@end

@implementation PLYOpine

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Opine";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-opine-text"])
	{
		self.text = value;
	}
	else if ([key isEqualToString:@"pl-parent"])
	{
		self.parent = [PLYEntity entityFromDictionary:value];
	}
	else if ([key isEqualToString:@"pl-prod-gtin"])
	{
		self.GTIN = value;
	}
	else if ([key isEqualToString:@"pl-lng"])
	{
		self.language = value;
	}
	else if ([key isEqualToString:@"pl-opine-location"])
	{
		PLYLocationCoordinate2D location;
		location.latitude = [value[@"latitude"] doubleValue];
		location.longitude = [value[@"longitude"] doubleValue];
		self.location = location;
	}
	else if ([key isEqualToString:@"pl-opine-img"])
	{
		if ([value isKindOfClass:[NSArray class]])
		{
			NSDictionary *dict = (NSDictionary *)value;
			NSMutableArray *tmpArray = [NSMutableArray array];
			
			for (NSDictionary *oneValue in dict)
			{
				PLYEntity *entity = [PLYEntity entityFromDictionary:oneValue];
				[tmpArray addObject:entity];
			}
			
			self.images = tmpArray;
		}
	}
	else if ([key isEqualToString:@"pl-prod"])
	{
		self.product = [[PLYProduct alloc] initWithDictionary:value];
	}
	else if ([key isEqualToString:@"pl-share-twitter"])
	{
		[self setValue:value forKey:@"shareOnTwitter"];
	}
	else if ([key isEqualToString:@"pl-share-facebook"])
	{
		[self setValue:value forKey:@"shareOnFacebook"];
	}
	else if ([key isEqualToString:@"pl-share-twitter-post_id"])
	{
		[self setValue:value forKey:@"twitterPostIdentifier"];
	}
	else if ([key isEqualToString:@"pl-share-facebook-post_id"])
	{
		[self setValue:value forKey:@"facebookPostIdentifier"];
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_text)
	{
		dict[@"pl-opine-text"] = _text;
	}
	
	if (_parent)
	{
		dict[@"pl-parent"] = [_parent objectReference];
	}
	
	if (_GTIN)
	{
		dict[@"pl-prod-gtin"] = _GTIN;
	}
	
	if (_language)
	{
		dict[@"pl-lng"] = _language;
	}
	
	if (_location.longitude && _location.latitude)
	{
		dict[@"pl-opine-location"] = @{@"latitude" : @(_location.latitude),
												 @"longitude" : @(_location.longitude)};
	}
	
	if (_shareOnFacebook)
	{
		dict[@"pl-share-facebook"] = @(_shareOnFacebook);
	}
	
	if (_shareOnTwitter)
	{
		dict[@"pl-share-twitter"] = @(_shareOnTwitter);
	}
	
	if ([_images count])
	{
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		for (PLYImage *image in _images)
		{
			[tmpArray addObject:[image dictionaryRepresentation]];
		}
		
		dict[@"pl-opine-img"] = tmpArray;
	}
	
	if (_product)
	{
		dict[@"pl-prod"] = [_product dictionaryRepresentation];
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYOpine *)entity
{
	[super updateFromEntity:entity];
	
	self.text = entity.text;
	self.parent = entity.parent;
	self.GTIN = entity.GTIN;
	self.product = entity.product;
	self.language = entity.language;
	self.location = entity.location;
	self.images = entity.images;
	self.shareOnTwitter = entity.shareOnTwitter;
	self.shareOnFacebook = entity.shareOnFacebook;
	
	self.facebookPostIdentifier = entity.facebookPostIdentifier;
	self.twitterPostIdentifier = entity.twitterPostIdentifier;
}

@end
