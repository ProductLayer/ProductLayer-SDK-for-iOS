//
//  PLYEntity.h
//  PL
//
//  Created by Oliver Drobnik on 08.07.14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

/**
 This is the super class of all entities returned by the SDK/API
 */

@class PLYAuditor;

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
 @name Common Properties
 */

/**
 The class identifier.
 */
@property (nonatomic, strong) NSString *Class;

/**
 The object id.
 */
@property (nonatomic, strong) NSString *Id;

/**
 The version.
 */
@property (nonatomic, strong) NSNumber *version;

/**
 The user who created the object.
 */
@property (nonatomic, strong) PLYAuditor *createdBy;

/**
 The timestamp when object was created.
 */
@property (nonatomic, strong) NSNumber *createdTime;

/**
 The user who updated the object the last time.
 */
@property (nonatomic, strong) PLYAuditor *updatedBy;

/**
 The timestamp when object was updated the last time.
 */
@property (nonatomic, strong) NSNumber *updatedTime;

@end
