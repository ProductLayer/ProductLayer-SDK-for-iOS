//
//  PLYNonEmptyValidator.m
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYNonEmptyValidator.h"

@implementation PLYNonEmptyValidator

- (void)validate
{
	[super validate];
	
	if (!self.valid)
	{
		return;
	}
	
	UITextField *field = (UITextField *)self.control;
	
	// trim the text
	NSString *text = [field.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	self.valid = ([text length]>0);
}

@end
