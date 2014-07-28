//
//  PLYList.m
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYList.h"

#import "DTLog.h"

#import "PLYListItem.h"
#import "PLYUser.h"

@implementation PLYList

+ (NSString *)entityTypeIdentifier
{
    return @"com.productlayer.List";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-created-by"])
	{
		
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.createdBy = [[PLYUser alloc] initWithDictionary:value];
		}
		
	}
	else if ([key isEqualToString:@"pl-list-products"])
	{
		
		if ([value isKindOfClass:[NSArray class]]) {
			
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
			for (id valueMember in value) {
				[myMembers addObject:[[PLYListItem alloc] initWithDictionary:valueMember]];
			}
			
			self.listItems = myMembers;
		}
	}
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.updatedBy = [[PLYUser alloc] initWithDictionary:value];
		}
		
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-list-title"])
	{
		[self setValue:value forKey:@"title"];
	}
	else if ([key isEqualToString:@"pl-list-desc"])
	{
		[self setValue:value forKey:@"descriptionText"];
	}
	else if ([key isEqualToString:@"pl-list-type"])
	{
		[self setValue:value forKey:@"listType"];
	}
	else if ([key isEqualToString:@"pl-list-share"])
	{
		[self setValue:value forKey:@"shareType"];
	}
	else if ([key isEqualToString:@"pl-list-shared-users"])
	{
		[self setValue:value forKey:@"sharedUsers"];
	}
	else
	{
		[super setValue:value forUndefinedKey:key];
	}
}

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (self.title)
	{
		[dict setObject:self.title forKey:@"pl-list-title"];
	}
	
	if (self.descriptionText)
	{
		[dict setObject:self.descriptionText forKey:@"pl-list-desc"];
	}
	
	if (self.listType)
	{
		[dict setObject:self.listType forKey:@"pl-list-type"];
	}
	
	if (self.shareType)
	{
		[dict setObject:self.shareType forKey:@"pl-list-share"];
	}
	
	if (self.sharedUsers)
	{
		[dict setObject:self.sharedUsers forKey:@"pl-list-shared-users"];
	}
	
	if (self.listItems)
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:1];
		
		for(PLYListItem *item in self.listItems)
		{
			[tmpArray addObject:[item dictionaryRepresentation]];
		}
		
		[dict setObject:tmpArray forKey:@"pl-list-products"];
	}
	
	// return immutable
	return [dict copy];
}

/**
 * Simple check if the product list can be send to the server for saving.
 **/
- (BOOL) isValidForSaving
{
	if([self.title length] > 5 && [self.listType length] && [self.shareType length])
	{
		return true;
	}
	
	return false;
}

+ (NSArray *)availableListTypes
{
	NSMutableArray *listTypes = [NSMutableArray arrayWithObjects:kLIST_WISHLIST,
										  kLIST_WISHLIST,
										  kLIST_BORROWED,
										  kLIST_OWNED,
										  kLIST_OTHER, nil];
	
	return listTypes;
}

+ (NSArray *)availableSharingTypes
{
	NSMutableArray *sharingTypes = [NSMutableArray arrayWithObjects:kSHARE_PUBLIC,
											  kSHARE_FRIENDS,
											  kSHARE_SPECIFIC,
											  kSHARE_NONE, nil];
	
	return sharingTypes;
}

@end
