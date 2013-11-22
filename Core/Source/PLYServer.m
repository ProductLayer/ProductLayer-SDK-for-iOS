//
//  PLYServer.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYServer.h"

@implementation PLYServer
{
	NSURL *_hostURL;
	NSOperationQueue *_queue;
}

- (instancetype)initWithHostURL:(NSURL *)hostURL
{
	NSParameterAssert(hostURL);
	
	self = [super init];
	
	if (self)
	{
		_hostURL = [hostURL copy];
		
		_queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 1;
	}
	
	return self;
}


#pragma mark - API Operations

- (void)performSearchForGTIN:(NSString *)gtin language:(NSString *)language completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	
	NSString *path = @"/ProductLayer/product/search";
	NSDictionary *parameters = @{@"gtin": gtin};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
	
	op.resultHandler = completion;
	
	[_queue addOperation:op];
}

@end
