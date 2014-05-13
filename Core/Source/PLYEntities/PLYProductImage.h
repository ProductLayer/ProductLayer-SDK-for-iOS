//
//  PLYProductImage.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

@class PLYAuditor;

/**
 * The metadata of the product images.
 **/
@interface PLYProductImage : NSObject {

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
    
    // The name of the image.
    NSString *name;
    // The gtin (barcode) of the product.
    NSString *gtin;

    // The image file id.
    NSString *fileId;
    
    // The height in pixel of the image.
    NSNumber *height;
    // The width in pixel of the image.
    NSNumber *width;
    
    // The url of the image.
    NSString *url;
    // The voting score of the image. (+1 for a up vote, -1 for a down vote)
    NSNumber *votingScore;
    // The users who up voted image.
    NSMutableArray *upVoters;
    // The users who down voted image.
    NSMutableArray *downVoters;
}

@property (nonatomic, strong) NSString *Class;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSNumber *version;

@property (nonatomic, strong) PLYAuditor *createdBy;
@property (nonatomic, strong) NSNumber *createdTime;
@property (nonatomic, strong) PLYAuditor *updatedBy;
@property (nonatomic, strong) NSNumber *updatedTime;

@property (nonatomic, strong) NSString *fileId;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *votingScore;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSMutableArray *upVoters;
@property (nonatomic, strong) NSMutableArray *downVoters;



+ (NSString *) classIdentifier;
+ (PLYProductImage *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

- (NSString *)getUrlForWidth:(CGFloat)maxWidth andHeight:(CGFloat)maxHeight crop:(BOOL)crop;

@end
