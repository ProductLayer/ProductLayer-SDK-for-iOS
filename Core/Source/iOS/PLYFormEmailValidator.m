//
//  PLYFormEmailValidator.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYFormEmailValidator.h"

@implementation PLYFormEmailValidator


- (BOOL)_isValidEmail:(NSString *)email
{
	if (![email length])
	{
		return NO;
	}
	
	NSRange entireRange = NSMakeRange(0, [email length]);
	NSDataDetector *detector =
	   [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
											  error:NULL];
	NSArray *matches = [detector matchesInString:email
													 options:0
														range:entireRange];
	
	// should only a single match
	if ([matches count]!=1)
	{
		return NO;
	}
	
	NSTextCheckingResult *result = [matches firstObject];
	
	// result should be a link
	if (result.resultType != NSTextCheckingTypeLink)
	{
		return NO;
	}
	
	// result should be a recognized mail address
	if (![result.URL.scheme isEqualToString:@"mailto"])
	{
		return NO;
	}
	
	// match must be entire string
	if (!NSEqualRanges(result.range, entireRange))
	{
		return NO;
	}
	
	// but schould not have the mail URL scheme
	if ([email hasPrefix:@"mailto:"])
	{
		return NO;
	}
	
	// no complaints, string is valid email address
	return YES;
}

- (void)validate
{
	[super validate];
	
	if (!self.valid)
	{
		// no further checking necessary
		return;
	}
	
	UITextField *field = (UITextField *)self.control;
	self.valid = [self _isValidEmail:field.text];
}

@end
