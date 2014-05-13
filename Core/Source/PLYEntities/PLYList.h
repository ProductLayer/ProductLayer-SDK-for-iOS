//
//  PLYList.h
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

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
 * With the product list you can group products which are important to you. Like a wishlist for your birthday.
 **/
@interface PLYList : NSObject {
    // The class identifier.
    NSString *Class;
    // The object id.
    NSString *Id;
    // The version.
    NSNumber *version;
    
    // The user who created the object.
    PLYAuditor *createdBy;
    // The timestamp when object was created.
    NSNumber *createdTime;
    
    // The user who updated the object the last time.
    PLYAuditor *updatedBy;
    // The timestamp when object was updated the last time.
    NSNumber *updatedTime;

    // The title of the list.
    NSString *title;
    // The description for the list.
    NSString *description;
    // The list type for the list.
    NSString *listType;
    
    // The sharing type for the list.
    NSString *shareType;
    // A list of user id's the product list is shared.
    NSArray *sharedUsers;
    
    // The list of products.
    NSMutableArray  *listItems;
}

@property (nonatomic, strong) NSString *Class;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSNumber *version;

@property (nonatomic, strong) PLYAuditor *createdBy;
@property (nonatomic, strong) NSNumber *createdTime;
@property (nonatomic, strong) PLYAuditor *updatedBy;
@property (nonatomic, strong) NSNumber *updatedTime;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *listType;

@property (nonatomic, strong) NSString *shareType;
@property (nonatomic, strong) NSArray *sharedUsers;

@property (nonatomic, strong) NSMutableArray *listItems;


+ (NSString *) classIdentifier;
+ (PLYList *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

- (BOOL) isValidForSaving;

+ (NSArray *) availableListTypes;
+ (NSArray *) availableSharingTypes;

@end
