//
//  PLYProduct.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@class PLYAuditor;
@class PLYPackaging;

@interface PLYProduct : PLYEntity

/**
 @name Properties
 */

// The class identifier.
@property (nonatomic, strong) NSString *Class;

// The object id.
@property (nonatomic, strong) NSString *Id;

// The name of the brand information.
@property (nonatomic, strong) NSString *brandName;

// The name of the brand owner information.
@property (nonatomic, strong) NSString *brandOwner;

// The user who created the object.
@property (nonatomic, strong) PLYAuditor *createdBy;

// The timestamp when object was created.
@property (nonatomic, strong) NSNumber *createdTime;

// The language of the product.
@property (nonatomic, strong) NSString *language;

// The product category
@property (nonatomic, strong) NSString *category;

// The detailed description of the product.
@property (nonatomic, strong) NSString *longDescription;

// The short description of the product.
@property (nonatomic, strong) NSString *shortDescription;

// The gtin (barcode) of the product.
@property (nonatomic, strong) NSString *gtin;

// The homepage or landingpage of the product.
@property (nonatomic, strong) NSString *homepage;

// Additional links for the product. e.g.: Support Forum, FAQ's, ...
@property (nonatomic, strong) NSArray *links;

// The name of the product.
@property (nonatomic, strong) NSString *name;

// The packaging information.
@property (nonatomic, strong) PLYPackaging *packaging;

// The product rating.
@property (nonatomic, strong) NSNumber *rating;

// The user who updated the object the last time.
@property (nonatomic, strong) PLYAuditor *updatedBy;

// The timestamp when object was updated the last time.
@property (nonatomic, strong) NSNumber *updatedTime;

// The version.
@property (nonatomic, strong) NSNumber *version;

// The characteristics information.
@property (nonatomic, strong) NSMutableDictionary *characteristics;

// The nutrition information.
@property (nonatomic, strong) NSMutableDictionary *nutritious;

@end
