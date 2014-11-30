//
//  PLYErrorMessage.h
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

/**
 * The error message with all needed information.
 **/
@interface PLYErrorMessage : PLYEntity

/**
 @name Properties
 */

/**
 The error message.
 */
@property (nonatomic, copy) NSString *message;

/**
 The productlayer error code.
 */
@property (nonatomic, assign) NSUInteger code;

/**
 The stacktrace will only be available for alpha and beta api's.
 */
@property (nonatomic, copy) NSString *throwable;

@end
