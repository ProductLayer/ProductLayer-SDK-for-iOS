//
//  PLYList.h
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@class PLYAuditor;

#define kLIST_WISHLIST  @"pl-list-type-wish"
#define kLIST_SHOPPING  @"pl-list-type-shopping"
#define kLIST_BORROWED  @"pl-list-type-borrowed"
#define kLIST_OWNED     @"pl-list-type-owned"
#define kLIST_OTHER     @"pl-list-type-other"

#define kSHARE_PUBLIC   @"pl-list-share-public"
#define kSHARE_FRIENDS  @"pl-list-share-friends"
#define kSHARE_SPECIFIC @"pl-list-share-specific"
#define kSHARE_NONE     @"pl-list-share-none"

/**
 With the product list you can group products which are important to you. Like a wishlist for your birthday.
 **/
@interface PLYList : PLYEntity

/**
 @name Properties
 */

/**
 The title of the list.
 */
@property (nonatomic, copy) NSString *title;

/**
 The description for the list.
 */
@property (nonatomic, copy) NSString *descriptionText;

/**
 The list type for the list.
 */
@property (nonatomic, copy) NSString *listType;

/**
 The sharing type for the list.
 */
@property (nonatomic, copy) NSString *shareType;

/**
 A list of user id's the product list is shared.
 */
@property (nonatomic, strong) NSArray *sharedUsers;

/**
 The list of products.
 */
@property (nonatomic, copy) NSArray *listItems;

/**
 @name Managing Lists
 */

- (BOOL) isValidForSaving;

+ (NSArray *) availableListTypes;
+ (NSArray *) availableSharingTypes;

@end
