//
//  PLYProblemReport.m
//  ProdlyApp
//
//  Created by Oliver Drobnik on 23/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYProblemReport.h"

@implementation PLYProblemReport

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.ProblemReport";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-report-description"])
	{
		[self setValue:value forKey:@"text"];
	}
	else if ([key isEqualToString:@"pl-report-obj_ref"])
	{
		[self setValue:value forKey:@"entity"];
	}
	else if ([key isEqualToString:@"pl-report-email"])
	{
		// ignore
	}
	else if ([key isEqualToString:@"pl-report-status"])
	{
		// ignore
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
		dict[@"pl-report-description"] = _text;
	}
	
	if (_entity)
	{
		dict[@"pl-report-obj_ref"] = [_entity objectReference];
	}
	
	// return immutable
	return [dict copy];
}

@end
