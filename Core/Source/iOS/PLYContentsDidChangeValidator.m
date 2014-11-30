//
//  PLYContentsDidChangeValidator.m
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYContentsDidChangeValidator.h"
#import "PLYFormValidator.h"

@implementation PLYContentsDidChangeValidator

+ (instancetype)validatorWithDelegate:(id<PLYFormValidationDelegate>)delegate originalContents:(NSString *)originalContents;
{
	PLYContentsDidChangeValidator *validator = (PLYContentsDidChangeValidator *)[[self class] validatorWithDelegate:delegate];
	validator->_originalContents = [originalContents copy];
	
	return validator;
}

- (void)validate
{
	[super validate];
	
	if (!self.valid)
	{
		return;
	}
	
	if (!_originalContents)
	{
		return;
	}
	
	UITextField *field = (UITextField *)self.control;
	
	self.valid = ![_originalContents isEqualToString:field.text];
}

@end
