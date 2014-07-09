//
//  PLYAuditor.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@interface PLYAuditor : PLYEntity

/**
 @name Properties
 */

/**
 The id of the user who created/updated the object
 */
@property (nonatomic, copy) NSString *userId;

/**
 The id of the application the object was created/updated with.
 */
@property (nonatomic, copy) NSString *appId;

/**
 The nickname of the user
 */
@property (nonatomic, copy) NSString *userNickname;

@end
