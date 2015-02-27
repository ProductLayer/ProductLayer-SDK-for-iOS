//
//  PLYReview.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYReview.h"

#import "PLYUser.h"
#import "PLYPackaging.h"

@implementation PLYReview

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Review";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-prod-gtin"])
	{
		self.GTIN = value;
	}
	else if ([key isEqualToString:@"pl-rev-subj"])
	{
		self.subject = value;
	}
	else if ([key isEqualToString:@"pl-rev-body"])
	{
		self.body = value;
	}
	else if ([key isEqualToString:@"pl-rev-rating"])
	{
		[self setValue:value forKey:@"rating"];
	}
	else if ([key isEqualToString:@"pl-lng"])
	{
		self.language = value;
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_GTIN)
	{
		dict[@"pl-prod-gtin"] = _GTIN;
	}
	
	if (_subject)
	{
		dict[@"pl-rev-subj"] = _subject;
	}
	
	if (_body)
	{
		dict[@"pl-rev-body"] = _body;
	}
	
	if (_rating)
	{
		dict[@"pl-rev-rating"] = @(_rating);
	}
	
	if (_language)
	{
		dict[@"pl-lng"] = _language;
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYReview *)entity
{
	[super updateFromEntity:entity];
	
	self.GTIN = entity.GTIN;
	self.subject = entity.subject;
	self.body = entity.body;
	self.rating = entity.rating;
	self.language = entity.language;
}

@end
