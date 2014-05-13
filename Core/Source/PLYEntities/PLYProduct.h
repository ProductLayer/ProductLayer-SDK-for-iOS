//
//  PLYProduct.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

@class PLYAuditor;
@class PLYPackaging;

@interface PLYProduct : NSObject
{
    // The class identifier.
    NSString *Class;
    // The object id.
    NSString *Id;
    // The version.
    NSNumber *version;
    
    // The user who created the object.
    PLYAuditor *createdBy;
    // The timestamp when object was created.
    NSNumber *createdTime;
    
    // The user who updated the object the last time.
    PLYAuditor *updatedBy;
    // The timestamp when object was updated the last time.
    NSNumber *updatedTime;
    
    // The gtin (barcode) of the product.
    NSString *gtin;
    // The name of the product.
    NSString *name;
    // The product category
    NSString *category;
    // The language of the product.
    NSString *language;
    
    // The short description of the product.
    NSString *shortDescription;
    // The detailed description of the product.
    NSString *longDescription;
    
    // The name of the brand information.
    NSString *brandName;
    // The name of the brand owner information.
    NSString *brandOwner;
    
    // The homepage or landingpage of the product.
    NSString *homepage;
    // Additional links for the product. e.g.: Support Forum, FAQ's, ...
    NSArray *links;
    
    // The packaging information.
    PLYPackaging *packaging;
    // The product rating.
    NSNumber *rating;
    
    // The characteristics information.
    NSMutableDictionary *characteristics;
    // The nutrition information.
    NSMutableDictionary *nutritious;
}

@property (nonatomic, strong) NSString *Class;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) NSString *brandOwner;
@property (nonatomic, strong) PLYAuditor *createdBy;
@property (nonatomic, strong) NSNumber *createdTime;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *longDescription;
@property (nonatomic, strong) NSString *shortDescription;
@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, strong) NSArray *links;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) PLYPackaging *packaging;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) PLYAuditor *updatedBy;
@property (nonatomic, strong) NSNumber *updatedTime;
@property (nonatomic, strong) NSNumber *version;
@property (nonatomic, strong) NSMutableDictionary *characteristics;
@property (nonatomic, strong) NSMutableDictionary *nutritious;

+ (NSString *) classIdentifier;

+ (PLYProduct *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;
@end
