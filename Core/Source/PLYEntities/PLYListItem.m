//
//  PLYListItem.m
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYListItem.h"

#import "DTLog.h"

@implementation PLYListItem

@synthesize Id;
@synthesize gtin;
@synthesize note;
@synthesize qty;
@synthesize prio;

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.ProductListItem";
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-prod-gtin"])
	{
		[self setValue:value forKey:@"gtin"];
	}
	else if ([key isEqualToString:@"pl-list-prod-note"])
	{
		[self setValue:value forKey:@"note"];
	}
	else if ([key isEqualToString:@"pl-list-prod-cnt"])
	{
		[self setValue:value forKey:@"qty"];
	}
	else if ([key isEqualToString:@"pl-list-prod-prio"])
	{
		[self setValue:value forKey:@"prio"];
	}
	else
	{
		[super setValue:value forUndefinedKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (gtin)
	{
		[dict setObject:gtin forKey:@"pl-prod-gtin"];
	}
	
	if (note)
	{
		[dict setObject:note forKey:@"pl-list-prod-note"];
	}
	
	if (qty)
	{
		[dict setObject:qty forKey:@"pl-list-prod-cnt"];
	}
	
	if (prio)
 {
		[dict setObject:prio forKey:@"pl-list-prod-prio"];
	}
	
	// return immutable
	return [dict copy];
}

@end
