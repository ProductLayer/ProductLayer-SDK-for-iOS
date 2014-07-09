//
//  PLYProductImage.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@class PLYAuditor;

/**
 * The metadata of the product images.
 **/
@interface PLYImage : PLYEntity

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
 The url of the image.
 */
@property (nonatomic, strong) NSString *url;

/**
 The voting score of the image. (+1 for a up vote, -1 for a down vote)
 */
@property (nonatomic, strong) NSNumber *votingScore;

/**
 The width in pixel of the image.
 */
@property (nonatomic, strong) NSNumber *width;

/**
 The gtin (barcode) of the product.
 */
@property (nonatomic, strong) NSString *gtin;

/**
 The users who up voted image.
 */
@property (nonatomic, strong) NSMutableArray *upVoters;

/**
 The users who down voted image.
 */
@property (nonatomic, strong) NSMutableArray *downVoters;


/**
 @name Working with Images
 */
- (NSString *)getUrlForWidth:(CGFloat)maxWidth andHeight:(CGFloat)maxHeight crop:(BOOL)crop;

@end
