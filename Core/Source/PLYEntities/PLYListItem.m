//
//  PLYListItem.m
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYListItem.h"

@implementation PLYListItem

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.ProductListItem";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-prod-gtin"])
	{
		self.GTIN = value;
	}
	else if ([key isEqualToString:@"pl-list-prod-note"])
	{
		self.note = value;
	}
	else if ([key isEqualToString:@"pl-list-prod-cnt"])
	{
		self.qty = value;
	}
	else if ([key isEqualToString:@"pl-list-prod-prio"])
	{
		self.prio = value;
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
	
	if (_note)
	{
		dict[@"pl-list-prod-note"] = _note;
	}
	
	if (_qty)
	{
		dict[@"pl-list-prod-cnt"] = _qty;
	}
	
	if (_prio)
	{
		dict[@"pl-list-prod-prio"] = _prio;
	}
	
	// return immutable
	return [dict copy];
}

@end
