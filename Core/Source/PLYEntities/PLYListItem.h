//
//  PLYListItem.h
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

/**
 * This object identifies a product in a product list.
 **/
@interface PLYListItem : PLYEntity {
    NSString *Id;
    // The gtin (barcode) of the product.
    NSString *gtin;
    // A simple note for people you share the list.
    NSString *note;
    // The amount for the list.
    NSNumber *qty;
    // The priority to sort the list. e.g.: Which present i prefer for my birthday.
    NSNumber *prio;
}

@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSString *note;
@property (nonatomic, strong) NSNumber *qty;
@property (nonatomic, strong) NSNumber *prio;

@end
