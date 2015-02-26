//
//  PLYList.m
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYList.h"
#import "PLYListItem.h"
#import "PLYUser.h"

@implementation PLYList

+ (NSString *)entityTypeIdentifier
{
    return @"com.productlayer.List";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-list-products"])
	{
		
		if ([value isKindOfClass:[NSArray class]]) {
			
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
			for (id valueMember in value) {
				[myMembers addObject:[[PLYListItem alloc] initWithDictionary:valueMember]];
			}
			
			self.listItems = myMembers;
		}
	}
	else if ([key isEqualToString:@"pl-list-title"])
	{
		self.title = value;
	}
	else if ([key isEqualToString:@"pl-list-desc"])
	{
		self.descriptionText = value;
	}
	else if ([key isEqualToString:@"pl-list-type"])
	{
		self.listType = value;
	}
	else if ([key isEqualToString:@"pl-list-share"])
	{
		self.shareType = value;
	}
	else if ([key isEqualToString:@"pl-list-shared-users"])
	{
		self.sharedUsers = value;
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_title)
	{
		dict[@"pl-list-title"] = _title;
	}
	
	if (_descriptionText)
	{
		dict[@"pl-list-desc"] = _descriptionText;
	}
	
	if (_listType)
	{
		dict[@"pl-list-type"] = _listType;
	}
	
	if (_shareType)
	{
		dict[@"pl-list-share"] = _shareType;
	}
	
	if (_sharedUsers)
	{
		dict[@"pl-list-shared-users"] = _sharedUsers;
	}
	
	if ([_listItems count])
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:1];
		
		for(PLYListItem *item in self.listItems)
		{
			[tmpArray addObject:[item dictionaryRepresentation]];
		}
		
		dict[@"pl-list-products"] = tmpArray;
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYList *)entity
{
	[super updateFromEntity:entity];
	
	self.title = entity.title;
	self.descriptionText = entity.descriptionText;
	self.listType = entity.listType;
	self.listItems = entity.listItems;
	self.shareType = entity.shareType;
	self.sharedUsers = entity.sharedUsers;
}

/**
 * Simple check if the product list can be send to the server for saving.
 **/
- (BOOL)isValidForSaving
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
