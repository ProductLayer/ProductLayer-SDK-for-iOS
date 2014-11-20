//
//  GenericAccount.m
//  ASiST
//
//  Created by Oliver on 09.11.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import "GenericAccount.h"
#import "AccountManager.h"
#import <Security/Security.h>
#import <Security/SecBase.h>
#import "DTLog.h"

@implementation GenericAccount
{
	NSDictionary *keychainData;
	NSMutableDictionary *newKeychainData;
}


#pragma mark Init/dealloc	

- (id)init
{
	NSAssert(YES, @"Use the queryForKeychainType factory method to get GenericAccounts");
	return nil;
}


- (instancetype)initWithService:(NSString *)service withAccount:(NSString *)account withKeychainType:(NSData *)keychainType
{
	self = [super init];
	
	if (self)
	{
		keychainData = nil;
		newKeychainData = [[NSMutableDictionary alloc] init];
		self.service = service;
		self.account = account;
		[newKeychainData setObject:(__bridge NSString *)kSecClassGenericPassword forKey:(__bridge NSString *)kSecClass];
		[newKeychainData setObject:keychainType forKey:(__bridge NSString *)kSecAttrGeneric];
	}
	return self;
}


- (instancetype)initFromKeychainDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if (self)
	{
		keychainData = dictionary;
		newKeychainData = [[NSMutableDictionary alloc] init];
		[newKeychainData setObject:(__bridge NSString *)kSecClassGenericPassword forKey:(__bridge NSString *)kSecClass];
	}
	
	return self;
}


// search query to find only this account on the keychain
+ (NSArray *)createGenericAccountsFromQueryResult:(id)result
{
	NSMutableArray *resultArray = [[NSMutableArray alloc] init];
	if ([result isKindOfClass:[NSDictionary class]])
	{
		GenericAccount *account = [[GenericAccount alloc] initFromKeychainDictionary:(NSDictionary *)result];
		[resultArray addObject:account];
	}
	else if ([result isKindOfClass:[NSArray class]])
	{
		NSArray *resultsAsArray = (NSArray *)result;

		for (NSDictionary *oneAccount in resultsAsArray)
		{
			GenericAccount *account = [[GenericAccount alloc] initFromKeychainDictionary:oneAccount];
			[resultArray addObject:account];
		}
	}
	return resultArray;
}


+ (NSArray *)queryForKeychainType:(NSData *)keychainType
{
	return [self queryForKeychainType:keychainType andService:nil];
}

+ (NSArray *)queryForKeychainType:(NSData *)keychainType andService:(NSString *)service
{
	NSMutableDictionary *queryDictionary = [[NSMutableDictionary alloc] init];
    
	[queryDictionary setObject:(__bridge NSString *)kSecClassGenericPassword forKey:(__bridge NSString *)kSecClass];
	[queryDictionary setObject:keychainType forKey:(__bridge NSString *)kSecAttrGeneric];
    
	if (service)
	{
		[queryDictionary setObject:service forKey:(__bridge NSString *)kSecAttrService];
	}
	
   [queryDictionary setObject:(__bridge NSString *)kSecMatchLimitAll forKey:(__bridge NSString *)kSecMatchLimit];
	[queryDictionary setObject:(__bridge id) kCFBooleanTrue forKey:(__bridge NSString *)kSecReturnAttributes];
	[queryDictionary setObject:(__bridge id) kCFBooleanTrue forKey:(__bridge NSString *)kSecReturnData];  // so password is also returned
    
	CFDataRef result = NULL;
	int matching = SecItemCopyMatching((__bridge CFDictionaryRef) queryDictionary, (CFTypeRef *)&result);
    
	if (matching == noErr)
	{
		NSData* resultData=(__bridge_transfer NSData*) result;
		return [self createGenericAccountsFromQueryResult:resultData];
	}
	
	return nil;
}

+ (NSDictionary *)queryKeychainDataForService:(NSString *)service andAccount:(NSString *)account
{
	NSDictionary *uniqueSearchQuery = [self searchQueryForService:service andAccount:account];
	DTLogDebug(@"uniqueSearchQuery %@", uniqueSearchQuery);
	CFDataRef result = NULL;
	
	int matching = SecItemCopyMatching((__bridge CFDictionaryRef)uniqueSearchQuery, (CFTypeRef *)&result);
	if (matching == noErr)
	{
		return (__bridge_transfer NSDictionary *) result;
	}
	return nil;
}


#pragma mark Keychain Access

+ (NSMutableDictionary *)searchQueryForService:service andAccount:account
{
	NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];

	[searchDictionary setObject:(__bridge NSString *)kSecClassGenericPassword forKey:(__bridge NSString *)kSecClass];
	[searchDictionary setObject:service forKey:(__bridge NSString *)kSecAttrService];
	[searchDictionary setObject:account forKey:(__bridge NSString *)kSecAttrAccount];
	[searchDictionary setObject:(__bridge id) kCFBooleanTrue forKey:(__bridge NSString *)kSecReturnAttributes];
	[searchDictionary setObject:(__bridge id) kCFBooleanTrue forKey:(__bridge NSString *)kSecReturnData];  // so password is also returned

	return searchDictionary;
}

- (NSMutableDictionary *)makeUniqueSearchQuery {
	NSString *service = [keychainData objectForKey:(__bridge NSString *)kSecAttrService];
	NSString *account = [keychainData objectForKey:(__bridge NSString *)kSecAttrAccount];
	return [GenericAccount searchQueryForService:service andAccount:account];
}


- (void)writeToKeychain
{
	if (keychainData)
	{
		NSDictionary *uniqueSearchQuery = [self makeUniqueSearchQuery];
		DTLogDebug(@"uniqueSearchQuery %@", uniqueSearchQuery);

		CFDataRef result = NULL;
		int matching = SecItemCopyMatching((__bridge CFDictionaryRef)uniqueSearchQuery, (CFTypeRef *)&result);
		
		if (matching == noErr)
		{
			// First we need the attributes from the Keychain.
			NSDictionary *resultData = (__bridge_transfer NSDictionary *) result;
			NSMutableDictionary *updateItem = [NSMutableDictionary dictionaryWithDictionary:resultData];
			DTLogDebug(@"updateItem result: %@", updateItem);

			[updateItem setObject:[uniqueSearchQuery objectForKey:(__bridge NSString *)kSecClass] forKey:(__bridge NSString *)kSecClass];

			// Lastly, we need to set up the updated attribute list being careful to remove the class.
			NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionaryWithDictionary:keychainData];
			[attributesToUpdate addEntriesFromDictionary: newKeychainData];
			[attributesToUpdate removeObjectForKey:(__bridge NSString *)kSecClass];

#ifdef TARGET_IPHONE_SIMULATOR
			// this causes the SecItemUpdate to crash because on simulator it's "test"
			[attributesToUpdate removeObjectForKey:@"agrp"];
#endif

			int result = SecItemUpdate((__bridge CFDictionaryRef) updateItem, (__bridge CFDictionaryRef) attributesToUpdate);

			if (result != noErr)
			{
				DTLogDebug(@"Error in Keychain so removing the item: %@", uniqueSearchQuery);
				[self removeFromKeychain];
				return;
			}
		}
	}
	else
	{
	// No previous item found, add the new one.
		OSStatus result = SecItemAdd((__bridge CFDictionaryRef) newKeychainData, NULL);
		if (result != noErr)
		{
			DTLogError(@"Couldn't add the Keychain Item: %d", (int)result);
		}
	}

	NSString *newService = self.service;
	NSString *newAccount = self.account;

	[newKeychainData removeAllObjects];
	keychainData  = [GenericAccount queryKeychainDataForService:newService andAccount:newAccount];
}

- (void)removeFromKeychain
{
	OSStatus junk;
	if (keychainData)
	{
		junk = SecItemDelete((__bridge CFDictionaryRef)[self makeUniqueSearchQuery]);
		NSAssert(junk == noErr || junk == errSecItemNotFound, @"Problem deleting current dictionary: %d", (int)junk);
	}
}


#pragma mark Setters

- (void) setAccount:(NSString *)newAccount
{
	[newKeychainData setObject:newAccount forKey:(__bridge NSString *)kSecAttrAccount];
}

- (NSString *)account
{
	NSString *result = [newKeychainData objectForKey:(__bridge NSString *)kSecAttrAccount];
	
	if (![result length])
	{
		result = [keychainData objectForKey:(__bridge NSString *)kSecAttrAccount];
	}
	return result;
}

- (NSString *)service
{
	NSString *result = [newKeychainData objectForKey:(__bridge NSString *)kSecAttrService];
	
	if (![result length])
	{
		result = [keychainData objectForKey:(__bridge NSString *)kSecAttrService];
	}
	return result;
}

- (void) setService:(NSString *)service
{
	[newKeychainData setObject:service forKey:(__bridge NSString *)kSecAttrService];
}

- (void) setPassword:(NSString *)newPassword
{
	[newKeychainData setObject:[newPassword dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge NSString *)kSecValueData];
}

- (NSString *)password
{
	NSString *result = [[NSString alloc] initWithData:[newKeychainData objectForKey:(__bridge NSString *)kSecValueData] encoding:NSUTF8StringEncoding];
	
	if (![result length])
	{
		result = [[NSString alloc] initWithData:[keychainData objectForKey:(__bridge NSString *)kSecValueData] encoding:NSUTF8StringEncoding];
	}
	
	return result;
}

- (NSString *)description
{
	NSString *result = [newKeychainData objectForKey:(__bridge NSString *)kSecAttrDescription];
	
	if (![result length])
	{
		result = [keychainData objectForKey:(__bridge NSString *)kSecAttrDescription];
	}
	return result;
}

- (void) setLabel:(NSString *)newLabel
{
	[newKeychainData setObject:newLabel forKey:(__bridge NSString *)kSecAttrLabel];
}

- (NSString *)label
{
	NSString *result = [newKeychainData objectForKey:(__bridge NSString *)kSecAttrLabel];
	
	if (![result length])
	{
		result = [keychainData objectForKey:(__bridge NSString *)kSecAttrLabel];
	}
	
	return result;
}

- (void) setComment:(NSString *)newComment
{
	[newKeychainData setObject:newComment forKey:(__bridge NSString *)kSecAttrComment];
}

- (NSString *)comment
{
	NSString *result = [newKeychainData objectForKey:(__bridge NSString *)kSecAttrComment];
	
	if (![result length])
	{
		result = [keychainData objectForKey:(__bridge NSString *)kSecAttrComment];
	}
	
	return result;
}

- (void) setDescriptionText:(NSString *)newDescription
{
	[newKeychainData setObject:newDescription forKey:(__bridge NSString *)kSecAttrDescription];
}

- (NSString *)descriptionText
{
	NSString *result = [newKeychainData objectForKey:(__bridge NSString *)kSecAttrDescription];
	
	if (![result length])
	{
		result = [keychainData objectForKey:(__bridge NSString *)kSecAttrDescription];
	}
	
	return result;
}



- (void)setType:(NSUInteger)type
{
	[newKeychainData setObject:[NSNumber numberWithUnsignedInteger:type] forKey:(__bridge NSString *)kSecAttrType];
}

- (NSUInteger)type
{
	NSUInteger result = [[newKeychainData objectForKey:(__bridge NSString *)kSecAttrType] unsignedIntegerValue];
	
	if (!result)
	{
		result = [[keychainData objectForKey:(__bridge NSString *)kSecAttrType] unsignedIntegerValue];
	}
	
	return result;
}


- (BOOL)isEqual:(id)object
{
	if ([object isKindOfClass:[GenericAccount class]])
	{
		GenericAccount *other = (GenericAccount *)object;
		return [self.service isEqual:other.service] && [self.account isEqual:other.account];
	}
	
	return [super isEqual:object];
}



- (BOOL)primaryKeyHasChanged
{
	NSString *newService = [newKeychainData objectForKey:(__bridge NSString *)kSecAttrService];
	NSString *oldService = [keychainData objectForKey:(__bridge NSString *)kSecAttrService];
	NSString *newAccount = [newKeychainData objectForKey:(__bridge NSString *)kSecAttrAccount];
	NSString *oldAccount = [keychainData objectForKey:(__bridge NSString *)kSecAttrAccount];

	if (newService != nil && ![newService isEqualToString:oldService])
	{
		return YES;
	}

	if (newAccount != nil && ![newAccount isEqualToString:oldAccount])
	{
		return YES;
	}
	
	return NO;
}

- (NSUInteger)hash
{
	NSString *service = [keychainData objectForKey:(__bridge NSString *)kSecAttrService];
	NSString *account = [keychainData objectForKey:(__bridge NSString *)kSecAttrAccount];
	NSString *hashString = [NSString stringWithFormat:@"%@@%@", account, service];
	NSUInteger result = hashString.hash;
	return result;
}


- (void)reset
{
	[newKeychainData removeAllObjects];
}

@end
