//
//  PLYFormValidator.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYFormValidator.h"

@implementation PLYFormValidator


- (instancetype)initWithDelegate:(id<PLYFormValidationDelegate>)delegate
{
   self = [super init];
   
   if (self)
   {
      _delegate = delegate;
		_valid = YES;
   }
   
   return self;
}


+ (instancetype)validatorWithDelegate:(id<PLYFormValidationDelegate>)delegate
{
   return [[[self class] alloc] initWithDelegate:delegate];
}

- (void)validate
{
   // subclasses define their own criteria what makes the control contents valid
	self.valid = YES;
}


#pragma mark - Properties

- (void)setValid:(BOOL)valid
{
	if (valid != _valid)
	{
		_valid = valid;
		
		if ([_delegate respondsToSelector:@selector(validityDidChange:)])
		{
			[_delegate validityDidChange:self];
		}
	}
}

@end
