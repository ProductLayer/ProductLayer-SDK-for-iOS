//
//  PLYProduct.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYVotableEntity.h"

@class PLYAuditor;
@class PLYPackaging;

/**
 API model class representing a product
 */

@interface PLYProduct : PLYVotableEntity

/**
 @name Properties
 */

/**
 The name of the brand information.
 */
@property (nonatomic, strong) NSString *brandName;

/**
 The name of the brand owner information.
 */
@property (nonatomic, strong) NSString *brandOwner;

/**
 The language of the product.
 *
@property (nonatomic, strong) NSString *language;

/**
 The product category
 */
@property (nonatomic, strong) NSString *category;

/**
 The detailed description of the product.
 */
@property (nonatomic, strong) NSString *longDescription;

/**
 The short description of the product.
 */
@property (nonatomic, strong) NSString *shortDescription;

/**
 The gtin (barcode) of the product.
 */
@property (nonatomic, strong) NSString *gtin;

/**
 The homepage or landingpage of the product.
 */
@property (nonatomic, strong) NSString *homepage;

/**
 Additional links for the product. e.g.: Support Forum, FAQ's, ...
 */
@property (nonatomic, strong) NSArray *links;

/**
 The name of the product.
 */
@property (nonatomic, strong) NSString *name;

/** 
 The packaging information.
 */
@property (nonatomic, copy) PLYPackaging *packaging;

/**
 The product rating.
 */
@property (nonatomic, strong) NSNumber *rating;

/**
 The characteristics information.
 */
@property (nonatomic, strong) NSMutableDictionary *characteristics;

/**
 The nutrition information.
 */
@property (nonatomic, strong) NSMutableDictionary *nutritious;

/**
 The source URL of the product information
 */
@property (nonatomic, copy) NSURL *sourceURL;

@end
