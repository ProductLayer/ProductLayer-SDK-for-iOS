//
//  PLYOpine.h
//  PL
//
//  Created by Oliver Drobnik on 29/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYVotableEntity.h"

/**
 Model object representing a user's opine
 */
@interface PLYOpine : PLYVotableEntity

/**
 @name Properties
 */

/**
 The text of the receiver.
 */
@property (nonatomic, strong) NSString *text;


@end
