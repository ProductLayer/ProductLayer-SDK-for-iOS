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
 * The metadata of the product images.
 **/
@interface PLYImage : PLYVotableEntity

/**
 @name Properties
 */

/**
 The image file id.
 */
@property (nonatomic, strong) NSString *fileId;

/**
 The height in pixel of the image.
 */
@property (nonatomic, strong) NSNumber *height;

/**
 The name of the image.
 */
@property (nonatomic, strong) NSString *name;

/**
 The URL of the image.
 */
@property (nonatomic, strong) NSString *url;

/**
 The width in pixel of the image.
 */
@property (nonatomic, strong) NSNumber *width;

/**
 The gtin (barcode) of the product.
 */
@property (nonatomic, copy) NSString *GTIN;


/**
 @name Working with Images
 */

- (NSString *)getUrlForWidth:(CGFloat)maxWidth andHeight:(CGFloat)maxHeight crop:(BOOL)crop;

@end
