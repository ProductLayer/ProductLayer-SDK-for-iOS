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
#import "NSString+DTURLEncoding.h"

#import "AppSettings.h"

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

#pragma mark Singleton Methods

+ (id)sharedPLYServer {
    static PLYServer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        _hostURL = PLY_ENDPOINT_URL;
        
        _queue = [[NSOperationQueue alloc] init];
		_queue.maxConcurrentOperationCount = 1;
		
		_uploadQueue = [[NSOperationQueue alloc] init];
		_uploadQueue.maxConcurrentOperationCount = 1;
		
		[self _loadState];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
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

+ (NSString *)_functionPathForFunction:(NSString *)function parameters:(NSDictionary *)parameters
{
	NSString *tmpString = @"/";
	
    function = [PLYServer _addQueryParameterToUrl:function parameters:parameters];
    
#ifdef PLY_PATH_PREFIX
	tmpString = [tmpString stringByAppendingPathComponent:PLY_PATH_PREFIX];
#endif
	
	tmpString = [tmpString stringByAppendingPathComponent:function];
	
	return tmpString;
}

+ (NSString *)_addQueryParameterToUrl:(NSString *)url parameters:(NSDictionary *)parameters{
    NSMutableString *tmpQuery = [NSMutableString string];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        if ([tmpQuery length])
        {
            [tmpQuery appendString:@"&"];
        }
        else
        {
            [tmpQuery appendString:@"?"];
        }
        
        [tmpQuery appendString:[key stringByURLEncoding]];
        
        [tmpQuery appendString:@"="];
        
        NSString *encoded = [[obj description] stringByURLEncoding];
        [tmpQuery appendString:encoded];
    }];
    
    if (parameters)
    {
        url = [url stringByAppendingString:tmpQuery];
    }
    
    return url;
}

- (NSURL *)imageURLForProductGTIN:(NSString *)gtin imageIdentifier:(NSString *)imageIdentifier maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight crop:(BOOL)crop
{
   NSString *tmpString = [NSString stringWithFormat:@"product/%@/images/%@", gtin, imageIdentifier];
   NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
    
   if (maxWidth>0)
   {
       [parameters setObject:[NSString stringWithFormat:@"%lu",(unsigned long)maxWidth] forKey:@"max_width"];
   }
    
   if (maxHeight>0)
   {
       [parameters setObject:[NSString stringWithFormat:@"%lu",(unsigned long)maxHeight] forKey:@"max_height"];
   }
    
    if (crop)
    {
        [parameters setObject:@"true" forKey:@"crop"];
    }
   
   NSString *path = [PLYServer _functionPathForFunction:tmpString parameters:parameters];
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
        [defaults removeObjectForKey:@"PLYBasicAuth"];
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
	
	[self performSearchForProduct:gtin
                             name:nil
                         language:language
                          orderBy:@"pl-lng_asc"
                             page:nil
                   recordsPerPage:nil
                       completion:completion];
}

- (void)performSearchForName:(NSString *)name language:(NSString *)language completion:(PLYAPIOperationResult)completion{
    NSParameterAssert(name);
	
	[self performSearchForProduct:nil
                             name:name
                         language:language
                          orderBy:@"pl-prod-name_asc"
                             page:nil
                   recordsPerPage:nil
                       completion:completion];
}

- (void)performSearchForProduct:(NSString *)gtin
                           name:(NSString *)name
                       language:(NSString *)language
                        orderBy:(NSString *)orderBy
                           page:(NSNumber *)page
                 recordsPerPage:(NSNumber *)rpp
                  completion:(PLYAPIOperationResult)completion
{
	NSString *path = [self _functionPathForFunction:@"products"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (gtin)       [parameters setObject:gtin     forKey:@"gtin"];
    if (language)   [parameters setObject:language forKey:@"language"];
    if (name)       [parameters setObject:name     forKey:@"name"];
    if (orderBy)    [parameters setObject:orderBy  forKey:@"order_by"];
    if (page)       [parameters setObject:page     forKey:@"page"];
    if (rpp)        [parameters setObject:rpp      forKey:@"records_per_page"];
	
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



- (void) getCategoriesForLocale:(NSString *)language completion:(PLYAPIOperationResult)completion{
    NSString *function = [NSString stringWithFormat:@"/products/categories?language=%@", language];
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
			
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:authValue forKey:@"PLYBasicAuth"];
            
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
	
    op.HTTPMethod = @"POST";
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

- (void)updateProductWithGTIN:(NSString *)gtin dictionary:(NSDictionary *)dictionary completion:(PLYAPIOperationResult)completion
{
	NSParameterAssert(gtin);
	
	NSString *path = [self _functionPathForFunction:[NSString stringWithFormat:@"/product/%@",gtin]];
	
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
	op.HTTPMethod = @"PUT";
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

#pragma mark - Reviews

- (void) performSearchForReviewWithGTIN:(NSString *)gtin
                           withLanguage:(NSString *)language
                   fromUserWithNickname:(NSString *)nickname
                             withRating:(NSNumber *)rating
                                orderBy:(NSString *)orderBy
                                   page:(NSNumber *)page
                         recordsPerPage:(NSNumber *)rpp
                             completion:(PLYAPIOperationResult)completion
{
	NSString *function = @"reviews";
	NSString *path = [self _functionPathForFunction:function];
	
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (gtin)       [parameters setObject:gtin     forKey:@"gtin"];
    if (language)   [parameters setObject:language forKey:@"language"];
    if (nickname)   [parameters setObject:nickname forKey:@"nickname"];
    if (rating)     [parameters setObject:rating   forKey:@"rating"];
    if (orderBy)    [parameters setObject:orderBy  forKey:@"order_by"];
    if (page)       [parameters setObject:page     forKey:@"page"];
    if (rpp)        [parameters setObject:rpp      forKey:@"records_per_page"];
    
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
    
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

- (void) createReviewForGTIN:(NSString *)gtin
           dictionary:(NSDictionary *)dictionary
           completion:(PLYAPIOperationResult)completion
{
	NSString *function = [NSString stringWithFormat:@"product/%@/review",gtin];
	NSString *path = [self _functionPathForFunction:function];
    
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:nil];
    op.HTTPMethod = @"POST";
	op.payload = dictionary;
    
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

#pragma mark - Lists

- (void) createProductList:(NSString *)gtin
                           withLanguage:(NSString *)language
                   fromUserWithNickname:(NSString *)nickname
                             withRating:(NSNumber *)rating
                                orderBy:(NSString *)orderBy
                                   page:(NSNumber *)page
                         recordsPerPage:(NSNumber *)rpp
                             completion:(PLYAPIOperationResult)completion
{
	NSString *function = @"reviews";
	NSString *path = [self _functionPathForFunction:function];
	
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (gtin)       [parameters setObject:gtin     forKey:@"gtin"];
    if (language)   [parameters setObject:language forKey:@"language"];
    if (nickname)   [parameters setObject:nickname forKey:@"nickname"];
    if (rating)     [parameters setObject:rating   forKey:@"rating"];
    if (orderBy)    [parameters setObject:orderBy  forKey:@"order_by"];
    if (page)       [parameters setObject:page     forKey:@"page"];
    if (rpp)        [parameters setObject:rpp      forKey:@"records_per_page"];
    
	PLYAPIOperation *op = [[PLYAPIOperation alloc] initWithEndpointURL:_hostURL functionPath:path parameters:parameters];
    
	op.resultHandler = completion;
	
	[self _enqueueOperation:op];
}

@end
