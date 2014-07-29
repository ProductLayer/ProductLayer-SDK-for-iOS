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

/**
 The parent entity that the receiver is about, can be any PLYEntity or even another PLYOpine
 */
@property (nonatomic, copy) PLYEntity *parent;

/**
 The barcode (GTIN) of the product that this opine refers to
 */
@property (nonatomic, copy) NSString *GTIN;

/**
 The language of the review.
 */
@property (nonatomic, copy) NSString *language;

@end
