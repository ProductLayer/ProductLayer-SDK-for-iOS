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
