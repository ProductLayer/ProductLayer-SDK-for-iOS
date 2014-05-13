//
//  PLYReview.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLYAuditor;

@interface PLYReview : NSObject {
    
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
    // The subject of the review.
    NSString *subject;
    // The detailed review text.
    NSString *body;
    // The rating for the product.
    NSNumber *rating;
    // The language of the review.
    NSString *language;
    
    // The sum of all votes (up +1, down -1).
    NSNumber *votingScore;
    // The list of user id's who up-voted the review.
    NSArray *upVoter;
    // The list of user id's who down-voted the review.
    NSArray *downVoter;
}

@property (nonatomic, strong) NSString *Class;
@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSNumber *version;

@property (nonatomic, strong) PLYAuditor *createdBy;
@property (nonatomic, strong) NSNumber *createdTime;
@property (nonatomic, strong) PLYAuditor *updatedBy;
@property (nonatomic, strong) NSNumber *updatedTime;

@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *language;

@property (nonatomic, strong) NSNumber *votingScore;
@property (nonatomic, strong) NSArray *upVoter;
@property (nonatomic, strong) NSArray *downVoter;



+ (NSString *) classIdentifier;
+ (PLYReview *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

@end
