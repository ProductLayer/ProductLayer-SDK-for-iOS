//
//  PLYPackaging.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@interface PLYPackaging : PLYEntity

/**
 @name Properties
 */

/**
 All what's packed into.
 */
@property (nonatomic, copy) NSString *contains;

/**
 The name of the package.
 */
@property (nonatomic, copy) NSString *name;

/** 
 The package description.
 */
@property (nonatomic, copy) NSString *description;

/**
 The units per package.
 */
@property (nonatomic, copy) NSNumber *unit;

@end
