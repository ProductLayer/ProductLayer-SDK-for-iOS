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

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-prod-gtin"])
	{
		[self setValue:value forKey:@"gtin"];
	}
	else if ([key isEqualToString:@"pl-rev-subj"])
	{
		[self setValue:value forKey:@"subject"];
	}
	else if ([key isEqualToString:@"pl-rev-body"])
	{
		[self setValue:value forKey:@"body"];
	}
	else if ([key isEqualToString:@"pl-rev-rating"])
	{
		[self setValue:value forKey:@"rating"];
	}
	else if ([key isEqualToString:@"pl-lng"])
	{
		[self setValue:value forKey:@"language"];
	}
	else
	{
		[super setValue:value forUndefinedKey:key];
	}
}

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_gtin)
	{
		[dict setObject:_gtin forKey:@"pl-prod-gtin"];
	}
	
	if (_subject)
	{
		[dict setObject:_subject forKey:@"pl-rev-subj"];
	}
	
	if (_body)
	{
		[dict setObject:_body forKey:@"pl-rev-body"];
	}
	
	if (_rating)
	{
		[dict setObject:_rating forKey:@"pl-rev-rating"];
	}
	
	if (_language)
	{
		[dict setObject:_language forKey:@"pl-lng"];
	}
	
	// return immutable
	return [dict copy];
}

@end
