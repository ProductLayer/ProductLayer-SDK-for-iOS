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

- (NSString *)getUrlForWidth:(CGFloat)maxWidth andHeight:(CGFloat)maxHeight crop:(BOOL)crop;

@end
