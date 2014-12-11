//
//  PLYOpine.m
//  PL
//
//  Created by Oliver Drobnik on 29/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYOpine.h"
#import "PLYImage.h"

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
				PLYImage *image = [[PLYImage alloc] initWithDictionary:oneValue];
				
				if (image)
				{
					[tmpArray addObject:image];
				}
			}
			
			self.images = tmpArray;
		}
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
	
	// return immutable
	return [dict copy];
}

@end
