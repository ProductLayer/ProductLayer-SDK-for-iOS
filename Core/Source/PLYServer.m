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
	NSOperationQueue *_uploadQueue;
	
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
		
		_uploadQueue = [[NSOperationQueue alloc] init];
		_uploadQueue.maxConcurrentOperationCount = 1;
		
		[self _loadState];
	}
	
	return self;
}

- (void)_enqueueOperation:(PLYAPIOperation *)operation
{
	operation.delegate = self;
	operation.accessToken = _accessToken;
	
	[_queue addOperation:operation];
}

- (void)_enqueueUploadOperation:(PLYAPIOperation *)operation
{
	operation.delegate = self;
	operation.accessToken = _accessToken;
	
	[_uploadQueue addOperation:operation];
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

- (NSURL *)imageURLForProductGTIN:(NSString *)gtin imageIdentifier:(NSString *)imageIdentifier maxWidth:(CGFloat)maxWidth
{
   NSString *tmpString = [NSString stringWithFormat:@"product/%@/images/%@", gtin, imageIdentifier];
   
   if (maxWidth>0)
   {
      tmpString = [tmpString stringByAppendingFormat:@"?max_width=%lu", (unsigned long)maxWidth];
   }
   
   NSString *path = [self _functionPathForFunction:tmpString];
   return [NSURL URLWithString:path relativeToURL:_hostURL];
}

- (void)_loadState
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	_accessToken = [defaults objectForKey:@"PLYServerAccessTokenKey"];
	_loggedInUser = [defaults objectForKey:@"PLYServerLoggedInUserKey"];
}

- (void)_storeState
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (_accessToken)
	{
		[defaults setObject:_accessToken forKey:@"PLYServerAccessTokenKey"];
	}
	else
	{
		[defaults removeObjectForKey:@"PLYServerAccessTokenKey"];
	}

	if (_loggedInUser)
	{
		[defaults setObject:_loggedInUser forKey:@"PLYServerLoggedInUserKey"];
	}
	else
	{
		[defaults removeObjectForKey:@"PLYServerLoggedInUserKey"];
	}
	
	[defaults synchronize];
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
	
	NSString *path = [self _functionPathForFunction:@"products"];
    NSLocale *locale = [NSLocale currentLocale];
	NSDictionary *parameters = @{@"gtin": gtin, @"language":locale.localeIdentifier};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

- (void)performSearchForName:(NSString *)name language:(NSString *)language completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(name);
	
	NSString *path = [self _functionPathForFunction:@"products"];
    NSLocale *locale = [NSLocale currentLocale];
	NSDictionary *parameters = @{@"name": name, @"language":locale.localeIdentifier};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

#pragma mark - Products

- (void)getImagesForGTIN:(NSString *)gtin completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	
	NSString *function = [NSString stringWithFormat:@"product/%@/images", gtin];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

- (void) getLastUploadedImagesWithPage:(int)page andRPP:(int)rpp completion:(PLYAPIOperationResult)completion{
	
	NSString *function = [NSString stringWithFormat:@"/products/images/last?page=%d&records_per_page=%d", page, rpp];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

#pragma mark - Managing Users

- (void)createUserWithUser:(NSString *)user email:(NSString *)email password:(NSString *)password completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(user);
	NSParameterAssert(email);
	NSParameterAssert(password);

	NSString *path = [self _functionPathForFunction:@"users"];

	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.HTTPMethod = @"POST";
	op.resultHandler = completion;
	
	NSDictionary *payloadDictionary = @{@"pl-usr-nickname": user, @"pl-usr-email": email, @"password": password};
	op.payload = payloadDictionary;
	
	[self _enqueueOperation:op];
}

- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(user);
	NSParameterAssert(password);
	
	NSString *path = [self _functionPathForFunction:@"user/login"];
	//NSDictionary *parameters = @{@"user": user, @"password": password};
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	
    // Basic Authentication
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", user, password];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    op.BasicAuthentication = authValue;
    op.HTTPMethod = @"POST";
    
	PLYAPIOperationResult wrappedCompletion = [completion copy];
	
	PLYAPIOperationResult ownCompletion = ^(id result, NSError *error) {
		
		if (!error && [result isKindOfClass:[NSDictionary class]])
		{
			NSString *token = result[@"access_token"];
			
			if (token)
			{
				_accessToken = token;
			}
			
			_loggedInUser = result[@"pl-usr-nickname"];
			
			[self _storeState];
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
	_loggedInUser = nil;
	
	[self _storeState];
}

#pragma mark - Managing Products

- (void)createProductWithGTIN:(NSString *)gtin dictionary:(NSDictionary *)dictionary completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	
	NSString *path = [self _functionPathForFunction:@"products"];
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.HTTPMethod = @"POST";
	op.payload = dictionary;
	
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

#pragma mark - Image Handling

- (void)uploadImageData:(UIImage *)data forGTIN:(NSString *)gtin completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	NSParameterAssert(data);
	
	NSString *function = [NSString stringWithFormat:@"product/%@/images", gtin];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.HTTPMethod = @"POST";
	op.payload = data;
	
	op.resultHandler = completion;
	
	[self _enqueueUploadOperation:op];
}

#pragma mark - File Handling

- (void)uploadFileData:(NSData *)data forGTIN:(NSString *)gtin completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	NSParameterAssert(data);
	
	NSString *function = [NSString stringWithFormat:@"product/%@/files", gtin];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.HTTPMethod = @"POST";
	op.payload = data;
	
	op.resultHandler = completion;
	
	[self _enqueueUploadOperation:op];
}

@end
