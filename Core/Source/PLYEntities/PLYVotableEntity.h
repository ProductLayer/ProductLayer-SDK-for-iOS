//
//  PLYVotableEntity.h
//  PL
//
//  Created by Oliver Drobnik on 29/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"

/**
 API Model object on which users can cast their votes
 */
@interface PLYVotableEntity : PLYEntity

/**
 @name Properties
 */

/**
 The sum of all votes (up +1, down -1).
 */
@property (nonatomic, strong) NSNumber *votingScore;

/**
 The list of user id's who up-voted the review.
 */
@property (nonatomic, copy) NSArray *upVoter;

/**
 The list of user id's who down-voted the review.
 */
@property (nonatomic, copy) NSArray *downVoter;

@end
