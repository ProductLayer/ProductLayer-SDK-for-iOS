//
//  PLYServer.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYServer.h"
#import "DTLog.h"

#if TARGET_OS_IPHONE
	#import "UIApplication+DTNetworkActivity.h"
#endif

@interface PLYServer () <PLYAPIOperationDelegate>

@end

@implementation PLYServer
{
	NSURL *_hostURL;
	NSOperationQueue *_queue;
	
	NSString *_accessToken;
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

- (void)_enqueueOperation:(PLYAPIOperation *)operation
{
	operation.delegate = self;
	operation.accessToken = _accessToken;
	
	[_queue addOperation:operation];
}

#pragma mark - PLYAPIOperationDelegate

- (void)operationWillExecute:(PLYAPIOperation *)operation
{
#if TARGET_OS_IPHONE
	[[UIApplication sharedApplication] pushActiveNetworkOperation];
#endif
}

- (void)operation:(PLYAPIOperation *)operation didExecuteWithError:(NSError *)error
{
#if TARGET_OS_IPHONE
	[[UIApplication sharedApplication] popActiveNetworkOperation];
#endif
	
	if (error)
	{
		DTLogError(@"PLYAPIOperation failed: %@", [error localizedDescription]);
	}
}

- (void)operation:(PLYAPIOperation *)operation didReceiveAccessToken:(NSString *)token
{
	_accessToken = token;
}

#pragma mark - API Operations

- (void)performSearchForGTIN:(NSString *)gtin language:(NSString *)language completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	
	NSString *path = @"/ProductLayer/product/search";
	NSDictionary *parameters = @{@"gtin": gtin};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

- (void)createUserWithUser:(NSString *)user email:(NSString *)email password:(NSString *)password completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(user);
	NSParameterAssert(email);
	NSParameterAssert(password);

	NSString *path = @"/ProductLayer/user/register";

	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.HTTPMethod = @"POST";
	op.resultHandler = completion;
	
	NSDictionary *payloadDictionary = @{@"user": user, @"email": email, @"password": password};
	op.payload = payloadDictionary;
	
	[self _enqueueOperation:op];
}

- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(user);
	NSParameterAssert(password);
	
	NSString *path = @"/ProductLayer/user/login";
	NSDictionary *parameters = @{@"user": user, @"password": password};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

- (void)logoutUserWithCompletion:(PLYAPIOperationResult)completion
{
	NSString *path = @"/ProductLayer/user/logout";
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

@end
