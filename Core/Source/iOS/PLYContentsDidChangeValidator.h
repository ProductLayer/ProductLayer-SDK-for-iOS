//
//  PLYContentsDidChangeValidator.h
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYNonEmptyValidator.h"

/**
 A specialized PLYFormValidator that checks that the text contents have been modified. Only changed contents are deemed valid.
 */
@interface PLYContentsDidChangeValidator : PLYNonEmptyValidator

/**
 Convenience constructor
 @param delegate The PLYFormValidatorDelegate object
 @param originalContents The original text contents
 */
+ (instancetype)validatorWithDelegate:(id<PLYFormValidationDelegate>)delegate originalContents:(NSString *)originalContents;

/**
 @name Properties
 */

/**
 The original contents to compare to
 */
@property (nonatomic, readonly) NSString *originalContents;

@end
