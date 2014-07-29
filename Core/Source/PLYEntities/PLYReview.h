//
//  PLYReview.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYVotableEntity.h"

@class PLYUser;

/**
 Model class representing a product review.
 */
@interface PLYReview : PLYVotableEntity

/**
 @name Properties
 */

/**
 The gtin (barcode) of the product.
 */
@property (nonatomic, strong) NSString *gtin;

/**
 The subject of the review.
 */
@property (nonatomic, strong) NSString *subject;

/**
 The detailed review text.
 */
@property (nonatomic, strong) NSString *body;

/**
 The rating for the product.
 */
@property (nonatomic, strong) NSNumber *rating;

/**
 The language of the review.
 */
@property (nonatomic, strong) NSString *language;

@end
