//
//  PLYEntity.h
//  PL
//
//  Created by Oliver Drobnik on 08.07.14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//


@class PLYUser;

/**
 This is the super class of all entities returned by the SDK/API
 */
@interface PLYEntity : NSObject

/**
 Returns the correct entity instance for a given dictionary or nil if there is no match
 @param dictionary The dictionary of entity values
 @returns A PLYEntity subclass that matches the object type from the dictionary
 */
+ (PLYEntity *)entityFromDictionary:(NSDictionary *)dictionary;

/**
 @name Subclass Methods
 */

/**
 Designated initializer to overwrite for subclasses
 @param dictionary A dictionary (decoded from JSON)
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 The class identifier string that identifies a PLYEntity subclass to be used for a given dictionary
 */
+ (NSString *)entityTypeIdentifier;

/**
 Creates a dictionary representation of the receiver
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 Creates an object reference (id + type) for the receiver
 @returns A dictionary to serve as objectReference for the receiver or `nil` if it cannot be constructed due to missing information.
 */
- (NSDictionary *)objectReference;

/**
 Updates an entity with values from another entity. This also sets values to zero or `nil` if they are so in the source entity
 @param entity The entity to get the new values for the receiver from
 */
- (void)updateFromEntity:(PLYEntity *)entity;

/**
 @name Common Properties
 */

/**
 The class identifier.
 */
@property (nonatomic, copy) NSString *Class;

/**
 The object id.
 */
@property (nonatomic, copy) NSString *Id;

/**
 The version.
 */
@property (nonatomic, assign) NSUInteger version;

/**
 The user who created the object.
 */
@property (nonatomic, strong) PLYUser *createdBy;

/**
 The timestamp when object was created.
 */
@property (nonatomic, strong) NSDate *createdTime;

/**
 The user who updated the object the last time.
 */
@property (nonatomic, strong) PLYUser *updatedBy;

/**
 The timestamp when object was updated the last time.
 */
@property (nonatomic, strong) NSDate *updatedTime;

@end
