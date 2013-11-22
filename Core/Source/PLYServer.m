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

- (void)createUserWithNickname:(NSString *)nickname email:(NSString *)email password:(NSString *)password completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(nickname);
	NSParameterAssert(email);
	NSParameterAssert(password);

	NSString *path = @"/ProductLayer/user/register";

	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.HTTPMethod = @"POST";
	op.resultHandler = completion;
	
	NSDictionary *payloadDictionary = @{@"nickName": nickname, @"email": email, @"password": password};
	op.payload = payloadDictionary;
	
	[_queue addOperation:op];
}

@end
