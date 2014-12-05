//
//  PLYBrandOwner.h
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"

/**
 A brand owner, typically owning one or more PLYBrand objects
 */
@interface PLYBrandOwner : PLYEntity

/**
 The name of the brand owner
 */
@property (nonatomic, copy) NSString *name;

/**
 The brands owned by this brand
 */
@property (nonatomic, copy) NSArray *brands;

@end
