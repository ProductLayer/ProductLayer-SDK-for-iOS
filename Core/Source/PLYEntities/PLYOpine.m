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


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-opine-text"])
	{
		[self setValue:value forKey:@"text"];
	}
	else
	{
		[super setValue:value forUndefinedKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_text)
	{
		[dict setObject:_text forKey:@"pl-opine-text"];
	}
	
	// return immutable
	return [dict copy];
}

@end
