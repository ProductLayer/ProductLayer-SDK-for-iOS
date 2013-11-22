//
//  PLYAPIOperation.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYAPIOperation.h"

@implementation PLYAPIOperation
{
	NSURL *_operationURL;
}

- (instancetype)initWithEndpointURL:(NSURL *)endpointURL functionPath:(NSString *)functionPath parameters:(NSDictionary *)parameters
{
	NSParameterAssert(endpointURL);
	NSParameterAssert(functionPath);
	
	self = [super init];
	
	if (self)
	{
		
		
		
		
	}
	
	return self;
}

@end
