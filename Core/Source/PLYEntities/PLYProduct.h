//
//  PLYProduct.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYVotableEntity.h"

@class PLYAuditor, PLYImage, PLYPackaging;

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
@property (nonatomic, copy) NSString *brandName;

/**
 The name of the brand owner information.
 */
@property (nonatomic, copy) NSString *brandOwner;

/**
 The language of the product.
 */
@property (nonatomic, copy) NSString *language;

/**
 The product category
 */
@property (nonatomic, copy) NSString *category;

/**
 The detailed description of the product.
 */
@property (nonatomic, copy) NSString *longDescription;

/**
 The short description of the product.
 */
@property (nonatomic, copy) NSString *shortDescription;

/**
 The GTIN (barcode) of the product.
 */
@property (nonatomic, copy) NSString *GTIN;

/**
 The homepage or landingpage of the product.
 */
@property (nonatomic, copy) NSString *homepage;

/**
 Additional links for the product. e.g.: Support Forum, FAQ's, ...
 */
@property (nonatomic, strong) NSArray *links;

/**
 The name of the product.
 */
@property (nonatomic, copy) NSString *name;

/**
 The default image of the product
 */
@property (nonatomic, copy) PLYImage *defaultImage;

/** 
 The packaging information.
 */
@property (nonatomic, copy) PLYPackaging *packaging;

/**
 The average product review rating.
 */
@property (nonatomic, assign) float averageReviewRating;

/**
 The number of user reviews for this product
 */
@property (nonatomic, assign) NSUInteger numberOfReviews;

/**
 The number of user opines for this product
 */
@property (nonatomic, assign) NSUInteger numberOfOpines;

/**
 The number of images for this product
 */
@property (nonatomic, assign) NSUInteger numberOfImages;

/**
 The characteristics information.
 */
@property (nonatomic, copy) NSDictionary *characteristics;

/**
 The nutrition information.
 */
@property (nonatomic, copy) NSDictionary *nutritious;

/**
 The source URL of the product information
 */
@property (nonatomic, copy) NSURL *sourceURL;

/**
 Other languages in which the receiver is localized
 */
@property (nonatomic, copy) NSArray *additionalLanguages;

/**
 Links where the product can be bought
 */
@property (nonatomic, copy) NSDictionary *buyLinks;

@end
