//
//  PLYList.h
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLYAuditor;

#define kLIST_WISHLIST  @"pl-list-type-wish"
#define kLIST_SHOPPING  @"pl-list-type-shopping"
#define kLIST_BORROWED  @"pl-list-type-borrowed"
#define kLIST_OWNED     @"pl-list-type-owned"
#define kLIST_OTHER     @"pl-list-type-other"

@interface PLYList : NSObject {
    NSString *Class;
    NSString *Id;
    NSNumber *version;

    PLYAuditor *createdBy;
    NSNumber *createdTime;

    PLYAuditor *updatedBy;
    NSNumber *updatedTime;

    NSString *title;
    NSString *description;
    NSString *listType;
    
    NSString *shareType;
    NSArray *sharedUsers;
    
    NSArray  *listItems;
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

@property (nonatomic, strong) NSArray *listItems;


+ (NSString *) classIdentifier;
+ (PLYList *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

@end
