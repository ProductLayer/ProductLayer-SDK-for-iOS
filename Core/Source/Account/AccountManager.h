//
//  AccountManager.h
//
//  Created by Oliver on 07.09.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenericAccount.h"

@interface AccountManager : NSObject {
}

/**
 Shared account manager
 */
+ (AccountManager *) sharedAccountManager;

/**
 Create a new account for the service. Doesn't save the account into the keychain. 
 Call saveGenericAccount to save the account.
 @param service The name of the service.
 @param account The name for the account.
 */
- (GenericAccount *) createGenericAccountForService:(NSString *)service forAccount:(NSString *)account;

/**
 Load an specific account from the keychain if available.
 @param service The name of the service.
 @param account The name for the account.
 */
- (GenericAccount *) loadGenericAccountForService:(NSString *)service forAccount:(NSString *)account;

/**
 Save an account into the keychain.
 @param account The account which will be saved.
 */
- (void) saveGenericAccount:(GenericAccount *)account;

/**
 Delete an account from the keychain.
 */
- (void) deleteGenericAccount:(GenericAccount *)account;

/**
 Delete an account from the keychain.
 @param account The name for the account.
 @param service The name of the service.
 */
- (void) deleteGenericAccount:(NSString *)account andService:(NSString *)service;

/**
 Check if the account for the service exists.
 @param service The name of the service.
 @param account The name for the account.
 */
- (BOOL) genericAccountExistsForService:(NSString *)service andAccount:(NSString *)account;

/**
 Get all accounts from the account manager
 */
- (NSArray *)accounts;

/**
 Get all accounts for a service from the account manager
 */
- (NSArray *)accountsForService:(NSString *)service;

@end
