//
//  PLYContentsDidChangeValidator.h
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYNonEmptyValidator.h"

@interface PLYContentsDidChangeValidator : PLYNonEmptyValidator

+ (instancetype)validatorWithDelegate:(id<PLYFormValidationDelegate>)delegate originalContents:(NSString *)originalContents;

@property (nonatomic, readonly) NSString *originalContents;

@end
