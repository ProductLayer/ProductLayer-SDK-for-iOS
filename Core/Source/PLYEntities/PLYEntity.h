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

@end
