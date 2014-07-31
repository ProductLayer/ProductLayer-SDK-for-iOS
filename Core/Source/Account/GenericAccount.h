//
//  GenericAccount.h
//
//  Created by Oliver on 09.11.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericAccount : NSObject 
{
}

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *service;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) NSUInteger type;

/**
 Check if primary key (service and account) has changed.
 */
- (BOOL)primaryKeyHasChanged;

/**
 Reset all data from the account.
 */
- (void)reset;

@end
