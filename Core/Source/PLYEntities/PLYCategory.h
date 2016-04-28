//
//  PLYCategory.h
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"

/**
 Entity representing a product category
 */
@interface PLYCategory : PLYEntity

/**
 The category key of the receiver
 */
@property (nonatomic, readonly) NSString *key;

/**
 The localized name of the receiver
 */
@property (nonatomic, readonly) NSString *localizedName;

/**
 The sub categories of the receiver
 */
@property (nonatomic, readonly) NSArray *subCategories;


// calculated categories

/**
 The indentation level (temporary)
 */
@property (nonatomic, assign) NSUInteger level;

/**
 The localized category path (temporary)
 */
@property (nonatomic, copy) NSString *localizedPath;

@end
