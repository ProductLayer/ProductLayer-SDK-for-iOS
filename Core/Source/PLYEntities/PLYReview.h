//
//  PLYReview.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@class PLYAuditor;

@interface PLYReview : PLYEntity

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

/**
 The sum of all votes (up +1, down -1).
 */
@property (nonatomic, strong) NSNumber *votingScore;

/**
 The list of user id's who up-voted the review.
 */
@property (nonatomic, strong) NSArray *upVoter;

/**
 The list of user id's who down-voted the review.
 */
@property (nonatomic, strong) NSArray *downVoter;

@end
