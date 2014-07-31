//
//  AccountManager.m
//
//  Created by Oliver on 07.09.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import "AccountManager.h"
#import <Security/Security.h>
#import "GenericAccount.h"

@interface GenericAccount(PrivateMethods)
- (id) initWithService:(NSString *)service withAccount:(NSString *)account withKeychainType:(NSData *)keychainType;
- (id) initFromKeychainDictionary:(NSDictionary *)dictionary;
+ (NSArray *)queryForKeychainType:(NSData *)keychainType;
+ (NSArray *)queryForKeychainType:(NSData *)keychainType andService:(NSString *)service;
+ (NSDictionary *)queryKeychainDataForService:(NSString *)service andAccount:(NSString *)account;
- (void)writeToKeychain;
- (void)removeFromKeychain;
@end

@implementation AccountManager


static AccountManager *_sharedPreferencesInstance = nil;


+ (AccountManager *) sharedAccountManager
{
	if (!_sharedPreferencesInstance)
	{
		_sharedPreferencesInstance = [[AccountManager alloc] init];
	}
	
	return _sharedPreferencesInstance;
}

- (GenericAccount *) createGenericAccountForService:(NSString *)service forAccount:(NSString *)account
{
    NSParameterAssert(service);
    NSParameterAssert(account);
    
	return [[GenericAccount alloc] initWithService:service withAccount:account withKeychainType:[self keychainType]];
}

- (GenericAccount *) loadGenericAccountForService:(NSString *)service forAccount:(NSString *)account
{
    NSParameterAssert(service);
    NSParameterAssert(account);
    
    NSDictionary *dictionary = [GenericAccount queryKeychainDataForService:service andAccount:account];
    
    if (dictionary)
    {
        return [[GenericAccount alloc] initFromKeychainDictionary:dictionary];
    }
    
    return nil;
}

- (BOOL) genericAccountExistsForService:(NSString *)service andAccount:(NSString *)account
{
    NSParameterAssert(service);
    NSParameterAssert(account);
    
     NSDictionary *dictionary = [GenericAccount queryKeychainDataForService:service andAccount:account];
    
    if (dictionary) return true;
    
    return false;
}

- (NSData *)keychainType
{
	NSString *identifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
	NSMutableData *data = [NSMutableData data];
	[data appendData:[identifier dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendBytes:"\0" length:1];
	return [NSData dataWithData:data];
}

- (id) init
{
	self = [super init];
	if (self) {
	}
	return self;
}


#pragma mark Adding/Removing Accounts

- (void) saveGenericAccount:(GenericAccount *)account
{
    NSParameterAssert(account);
    
    [account writeToKeychain];
}

- (void) deleteGenericAccount:(GenericAccount *)account
{
    NSParameterAssert(account);
    
    [account removeFromKeychain];
}

- (void) deleteGenericAccount:(NSString *)account andService:(NSString *)service{
    NSParameterAssert(service);
    NSParameterAssert(account);
    
    GenericAccount *foundAccount = [self loadGenericAccountForService:service forAccount:account];
    
    if(foundAccount){
        [foundAccount removeFromKeychain];
    }
}

#pragma mark Retrieving Accounts

- (NSArray *)accounts
{
	return [GenericAccount queryForKeychainType:[self keychainType]];
}

- (NSArray *)accountsForService:(NSString *)service{
    return [GenericAccount queryForKeychainType:[self keychainType] andService:service];
}

@end
