//
//  PLYServer.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYServer.h"
#import "DTLog.h"
#import "ProductLayerConfig.h"

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

- (NSString *)_functionPathForFunction:(NSString *)function
{
	NSString *tmpString = @"/";
	
#ifdef PLY_PATH_PREFIX
	tmpString = [tmpString stringByAppendingPathComponent:PLY_PATH_PREFIX];
#endif
	
	tmpString = [tmpString stringByAppendingPathComponent:function];
	
	return tmpString;
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

#pragma mark - Search

- (void)performSearchForGTIN:(NSString *)gtin language:(NSString *)language completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	
	NSString *path = [self _functionPathForFunction:@"product/search"];
	NSDictionary *parameters = @{@"gtin": gtin};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

- (void)performSearchForName:(NSString *)name language:(NSString *)language completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(name);
	
	NSString *path = [self _functionPathForFunction:@"product/search"];
	NSDictionary *parameters = @{@"name": name};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

#pragma mark - Managing Users

- (void)createUserWithUser:(NSString *)user email:(NSString *)email password:(NSString *)password completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(user);
	NSParameterAssert(email);
	NSParameterAssert(password);

	NSString *path = [self _functionPathForFunction:@"user/register"];

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
	
	NSString *path = [self _functionPathForFunction:@"user/login"];
	NSDictionary *parameters = @{@"user": user, @"password": password};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
	
	PLYAPIOperationResult wrappedCompletion = [completion copy];
	
	PLYAPIOperationResult ownCompletion = ^(id result, NSError *error) {
		
		if (!error && [result isKindOfClass:[NSDictionary class]])
		{
			NSString *token = result[@"access_token"];
			
			if (token)
			{
				_accessToken = token;
			}
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	op.resultHandler = ownCompletion;
	
	[self _enqueueOperation:op];
}

- (void)logoutUserWithCompletion:(PLYAPIOperationResult)completion
{
	NSString *path = [self _functionPathForFunction:@"user/logout"];
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
	
	_accessToken = nil;
}

#pragma mark - Managing Products

- (void)createProductWithGTIN:(NSString *)gtin dictionary:(NSDictionary *)dictionary completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	
	NSString *path = [self _functionPathForFunction:@"product"];
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.HTTPMethod = @"POST";
	op.payload = dictionary;
	
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
	
}

@end
