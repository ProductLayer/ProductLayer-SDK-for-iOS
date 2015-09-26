//
//  PLYProductImage.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYVotableEntity.h"

@class PLYAuditor;

/**
 The metadata of the product images.
 */
@interface PLYImage : PLYVotableEntity

/**
 @name Properties
 */

/**
 The image file id.
 */
@property (nonatomic, copy) NSString *fileId;

/**
 The height in pixel of the image.
 */
@property (nonatomic, assign) NSUInteger height;

/**
 The name of the image.
 */
@property (nonatomic, copy) NSString *name;

/**
 The URL of the image.
 */
@property (nonatomic, strong) NSURL *imageURL;

/**
 The width in pixel of the image.
 */
@property (nonatomic, assign) NSUInteger width;

/**
 The gtin (barcode) of the product.
 */
@property (nonatomic, copy) NSString *GTIN;

/**
 The dominant color of the image in #RRGGBB
 */
@property (nonatomic) NSString *dominantColor;

@end
