//
//  PLYOpine.m
//  PL
//
//  Created by Oliver Drobnik on 29/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYOpine.h"

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
		dict[@"pl-parent"] = [_parent dictionaryRepresentation];
	}
	
	if (_GTIN)
	{
		dict[@"pl-prod-gtin"] = _GTIN;
	}
	
	if (_language)
	{
		dict[@"pl-lng"] = _language;
	}
	
	// return immutable
	return [dict copy];
}

@end
