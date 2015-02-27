//
//  PLYListItem.h
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@class PLYProduct;

/**
 This object identifies a product in a product list.
 **/
@interface PLYListItem : PLYEntity

/**
 @name Properties
 */

/**
 The GTIN (barcode) of the product.
 */
@property (nonatomic, copy) NSString *GTIN;

/**
 A simple note for people you share the list.
 */
@property (nonatomic, copy) NSString *note;

/**
 The amount for the list.
 */
@property (nonatomic, assign) NSUInteger quantity;

/**
 The priority to sort the list. e.g.: Which present i prefer for my birthday.
*/
@property (nonatomic, assign) NSUInteger priority;

/**
 The PLYProduct matching the GTIN and in the best matching language
 */
@property (nonatomic, strong) PLYProduct *product;

@end
