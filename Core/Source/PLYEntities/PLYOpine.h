//
//  PLYOpine.h
//  PL
//
//  Created by Oliver Drobnik on 29/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYVotableEntity.h"

typedef struct { double latitude; double longitude; } PLYLocationCoordinate2D;

@class PLYProduct;

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
@property (nonatomic, copy) NSString *text;

/**
 The parent entity that the receiver is about, can be any PLYEntity or even another PLYOpine
 */
@property (nonatomic, copy) PLYEntity *parent;

/**
 The barcode (GTIN) of the product that this opine refers to
 */
@property (nonatomic, copy) NSString *GTIN;


/**
 The PLYProduct matching the GTIN and in the best matching language
 */
@property (nonatomic, strong) PLYProduct *product;

/**
 The language of the review.
 */
@property (nonatomic, copy) NSString *language;

/**
 The geocoordinate of the receiver
 */
@property (nonatomic, assign) PLYLocationCoordinate2D location;

/**
 Images associated with the receiver
 */
@property (nonatomic, copy) NSArray *images;

/**
 Whether the receiver should be shared on Twitter
 */
@property (nonatomic, assign) BOOL shareOnTwitter;

/**
 Whether the receiver should be shared on Facebook
 */
@property (nonatomic, assign) BOOL shareOnFacebook;


/**
 If the opine was cross-posted to Twitter, this is the identifier
 */
@property (nonatomic, copy, readonly) NSString *twitterPostIdentifier;

/**
 If the opine was cross-posted to Facebook, this is the identifier
 */
@property (nonatomic, copy, readonly) NSString *facebookPostIdentifier;

@end
