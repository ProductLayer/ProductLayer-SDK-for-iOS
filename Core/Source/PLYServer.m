//
//  PLYServer.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductLayer.h"

#import "DTLog.h"
#import "NSString+DTURLEncoding.h"
#import "DTBlockFunctions.h"
#import "DTKeychain.h"
#import "DTKeychainGenericPassword.h"

#if TARGET_OS_IPHONE
#import "UIApplication+DTNetworkActivity.h"
#endif


// this is the URL for the endpoint server
#define PLY_ENDPOINT_URL [NSURL URLWithString:@"https://api.productlayer.com"]

// this is a prefix added before REST methods, e.g. for a version of the API
#define PLY_PATH_PREFIX @"0.3"

#define PLY_SERVICE [PLY_ENDPOINT_URL absoluteString]


@implementation PLYServer
{
	NSURL *_hostURL;
	NSString *_APIKey;
	
	NSURLSession *_session;
	NSURLSessionConfiguration *_configuration;
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
	self = [super init];
	
	if (self)
	{
		_hostURL = PLY_ENDPOINT_URL;
		_configuration = configuration;
	}
	
	return self;
}

// designated initializer
- (instancetype)init
{
    _performingLogin = NO;
    
	// use default config, we need credential & caching
	NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
	return [self initWithSessionConfiguration:config];
}

#pragma mark Singleton Methods

+ (id)sharedServer
{
	static PLYServer *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	return instance;
}

- (void)setAPIKey:(NSString *)APIKey
{
	_APIKey = APIKey;
	
	// load last state (login user)
	[self _loadState];
}

#pragma mark - Request Handling

// construct a suitable error
- (NSError *)_errorWithCode:(NSUInteger)code message:(NSString *)message {
	NSDictionary *userInfo;
	
	if (message)
	{
		userInfo = @{NSLocalizedDescriptionKey : message};
	}
	
	return [NSError errorWithDomain:PLYErrorDomain
										code:code
								  userInfo:userInfo];
}

// constructs the path for a method call
- (NSURL *)_methodURLForPath:(NSString *)path
                  parameters:(NSDictionary *)parameters {
	// turns the API_ENDPOINT into NSURL
	NSURL *endpointURL = PLY_ENDPOINT_URL;
	
	if ([parameters count])
	{
		// sort keys to get same order every time
		NSArray *sortedKeys =
		[[parameters allKeys]
		 sortedArrayUsingSelector:@selector(compare:)];
		
		// construct query string
		NSMutableArray *tmpArray = [NSMutableArray array];
		
		for (NSString *key in sortedKeys)
		{
			NSString *value = parameters[key];
			
			// URL-encode
			NSString *encKey = [key stringByURLEncoding];
			if([value isKindOfClass:[NSString class]])
			{
				value = [value stringByURLEncoding];
			}
			
			// combine into pairs
			NSString *tmpStr = [NSString stringWithFormat:@"%@=%@",
									  encKey, value];
			[tmpArray addObject:tmpStr];
		}
		
		// append query to path
		path = [path stringByAppendingFormat:@"?%@",
				  [tmpArray componentsJoinedByString:@"&"]];
	}
	
	return [NSURL URLWithString:path
					  relativeToURL:endpointURL];
}

- (void)_performMethodCallWithPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
                        completion:(PLYCompletion)completion{
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:parameters payload:nil basicAuth:nil completion:completion];
}

- (void)_performMethodCallWithPath:(NSString *)path
                        HTTPMethod:(NSString *)HTTPMethod
                        parameters:(NSDictionary *)parameters
                        completion:(PLYCompletion)completion {
	[self _performMethodCallWithPath:path HTTPMethod:HTTPMethod parameters:parameters payload:nil basicAuth:nil completion:completion];
}

- (void)_performMethodCallWithPath:(NSString *)path
                        HTTPMethod:(NSString *)HTTPMethod
                        parameters:(NSDictionary *)parameters
                           payload:(id)payload
                        completion:(PLYCompletion)completion{
	[self _performMethodCallWithPath:path HTTPMethod:HTTPMethod parameters:parameters payload:payload basicAuth:nil completion:completion];
}

- (void)_performMethodCallWithPath:(NSString *)path
                        HTTPMethod:(NSString *)HTTPMethod
                        parameters:(NSDictionary *)parameters
                         basicAuth:(NSString *)basicAuth
                        completion:(PLYCompletion)completion{
	[self _performMethodCallWithPath:path HTTPMethod:HTTPMethod parameters:parameters payload:nil basicAuth:basicAuth completion:completion];
}

// internal method that executes actual API calls
- (void)_performMethodCallWithPath:(NSString *)path
                        HTTPMethod:(NSString *)HTTPMethod
                        parameters:(NSDictionary *)parameters
                           payload:(id)payload
                         basicAuth:(NSString *)basicAuth
                        completion:(PLYCompletion)completion
{
	NSURL *methodURL = [self _methodURLForPath:path
											  parameters:parameters];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:methodURL];
	
	// set method if set
	if (HTTPMethod)
	{
		request.HTTPMethod = HTTPMethod;
	}

	// Set basic authorization if available
	if (basicAuth)
	{
		[request setValue:basicAuth forHTTPHeaderField:@"Authorization"];
	}
	
	// Add the API key to each request.
   NSAssert(_APIKey, @"Setting an API Key is required to perform requests. Use [[PLYServer sharedServer] setAPIKey:]");
	[request setValue:_APIKey forHTTPHeaderField:@"API-KEY"];
	
	NSMutableString *debugMessage = [NSMutableString string];
	[debugMessage appendFormat:@"%@ %@\n", request.HTTPMethod, [methodURL absoluteString]];
	
	// add body if set
	if (payload)
	{
		NSData *payloadData;
		
		if ([payload isKindOfClass:[DTImage class]])
		{
			payloadData = DTImageJPEGRepresentation(payload, 0.8);
			[request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
			request.timeoutInterval = 60;
		}
		else if ([payload isKindOfClass:[NSData class]])
		{
			payloadData = [payload copy];
			[request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
			
			request.timeoutInterval = 60;
		}
		else if ([NSJSONSerialization isValidJSONObject:payload])
		{
			payloadData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:NULL];
			[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			request.timeoutInterval = 10;
		}
		
		// set header fields
		NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[payloadData length]];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		
		// set the body
		request.HTTPBody = payloadData;
	}
	
	[self startDataTaskForRequest:request completion:completion];
}

- (void)startDataTaskForRequest:(NSMutableURLRequest *)request completion:(PLYCompletion)completion
{
#if TARGET_OS_IPHONE
	// increment active requests
	[[UIApplication sharedApplication] pushActiveNetworkOperation];
#endif
	
	// remember user that was logged in when task was started
	PLYUser *user = _loggedInUser;
	
	NSURLSessionDataTask *task = [[self session]
											dataTaskWithRequest:request
											completionHandler:^(NSData *data,
																	  NSURLResponse *response,
																	  NSError *error) {
#if TARGET_OS_IPHONE
												// decrement active requests
												[[UIApplication sharedApplication] popActiveNetworkOperation];
#endif
												
												NSError *retError = error;
												id result = nil;
												
												// check for transport error, e.g. no network connection
												if (retError) {
													
													completion(nil, retError);
													return;
												}
												
												// check if we stayed on API endpoint (invalid host might be redirected via OpenDNS)
												NSString *calledHost = [request.URL host];
												NSString *responseHost = [response.URL host];
												
												if (![responseHost isEqualToString:calledHost]) {
													NSString *msg = [NSString stringWithFormat:
																		  @"Expected result host to be '%@' but was '%@'",
																		  calledHost, responseHost];
													retError = [self _errorWithCode:999 message:msg];
													completion(nil, retError);
													return;
												}
												
												/*
												 // save response into a data file for unit testing
												 NSArray *writablePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
												 NSString *documentsPath = [writablePaths lastObject];
												 NSString *fileInDocuments = [documentsPath stringByAppendingPathComponent:@"data.txt"];
												 
												 [data writeToFile:fileInDocuments atomically:NO];
												 NSLog(@"output at %@", fileInDocuments);
												 */
												// needs to be a HTTP response to get the content type and status
												if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
													NSString *msg = @"Response is not an NSHTTPURLResponse";
													retError = [self _errorWithCode:999 message:msg];
													completion(nil, retError);
													return;
												}
												
												// check for protocol error
												NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
												NSDictionary *headers = [httpResp allHeaderFields];
												NSString *contentType = headers[@"Content-Type"];
												BOOL ignoreContent = NO;
												long statusCode = httpResp.statusCode;
												
												if ([data length])
												{
													if ([contentType hasPrefix:@"application/json"])
													{
														
													}
													else if ([contentType hasPrefix:@"text/plain"])
													{
														if (statusCode >= 200 && statusCode < 300)
														{
															NSString *plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
															DTLogDebug(@"%@", plainText);
															
															ignoreContent = YES;
                                                            
                                                            result = plainText;
														}
														else
														{
															NSString *plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
															NSString *errorMessage = [NSString stringWithFormat:@"Server returned plain text error '%@'", plainText];
															
															NSDictionary *userInfo = @{NSLocalizedDescriptionKey:  errorMessage};
															error = [NSError errorWithDomain:PLYErrorDomain code:0 userInfo:userInfo];
                                                            
                                                            result = plainText;
														}
													} else if ([contentType hasPrefix:@"text/html"])
													{
														ignoreContent = YES;
													}
													else
													{
														NSString *errorMessage = [NSString stringWithFormat:@"Unknown response content type '%@'", contentType];
														
														NSDictionary *userInfo = @{NSLocalizedDescriptionKey:  errorMessage};
														error = [NSError errorWithDomain:PLYErrorDomain code:0 userInfo:userInfo];
													}
												}
												
												if (user)
												{
													NSNumber *pointsNum = headers[@"X-ProductLayer-User-Points"];
													
													if (pointsNum)
													{
														[user setValue:pointsNum forKey:@"points"];
													}
												}
												
												if (!error && !ignoreContent)
												{
													id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
													
													// Try to parse the json object
													if ([jsonObject isKindOfClass:[NSArray class]] && [jsonObject count])
													{
														NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:1];
														
														for (NSDictionary *dictObject in jsonObject)
														{
															if (![dictObject isKindOfClass:[NSDictionary class]])
															{
																break;
															}
															
															id object = [PLYEntity entityFromDictionary:dictObject];
															
															if (!object)
															{
																continue;
															}
															
															[objectArray addObject:object];
														}
														
														// If the objects couldn't be parsed return the json object.
														if(objectArray.count > 0){
															result = objectArray;
														} else {
															result = jsonObject;
														}
													} else if ([jsonObject isKindOfClass:[NSDictionary class]]){
														id object = [PLYEntity entityFromDictionary:jsonObject];
														
														if(object == nil) {
															result = jsonObject;
														}
														else {
															result = object;
														}
													}
												}
												
												if (statusCode >= 400) {
													PLYErrorResponse *errorResponse = [[PLYErrorResponse alloc] initWithDictionary:result];
													
													if(errorResponse && [errorResponse.errors count] > 0){
														retError = [self _errorWithCode:statusCode
																						message:((PLYErrorMessage *)[errorResponse.errors objectAtIndex:0]).message];
													} else {
														retError = [self _errorWithCode:statusCode
																						message:[NSHTTPURLResponse localizedStringForStatusCode:(NSInteger)statusCode]];
													}
													
													// error(s) means that there was no usable result
													result = nil;
												}
												
												completion(result, retError);
											}];
	
	// tasks are created suspended, this starts it
	[task resume];
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

// FIXME: Clean this up, this should not be a private class method
+ (NSString *)_addQueryParameterToUrl:(NSString *)url parameters:(NSDictionary *)parameters {
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

#pragma mark - load and store state

- (void)_loadState
{
	DTKeychain *keychain = [DTKeychain sharedInstance];
	NSArray *serviceAccounts = [keychain keychainItemsMatchingQuery:[DTKeychainGenericPassword keychainItemQueryForService:PLY_SERVICE account:nil] error:NULL];
	
	if ([serviceAccounts count]>1)
	{
		// There should be only one account for productlayer for security reasons delete all accounts
		
		for (DTKeychainItem *item in serviceAccounts)
		{
			[keychain removeKeychainItem:item error:NULL];
		}
		
		DTLogError(@"Found %d keychain items for service '%@', where maximum one was expected. Deleted all items.", [serviceAccounts count], PLY_SERVICE);
		
		return;
	}
	
	DTKeychainGenericPassword *account = [serviceAccounts firstObject];
	
	if (account)
	{
		DTLogInfo(@"Logging in user '%@'", account.account);
		
		[self loginWithUser:account.account password:account.password completion:^(id result, NSError *error) {
			if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == kCFURLErrorNotConnectedToInternet)
			{
				// no Internet
				return;
			}
			
			if (error)
			{
				DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					NSDictionary *userInfo = @{@"Error": error};
					[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerLoginErrorNotification
																						 object:self
																					  userInfo:userInfo];
					
					// Delete account from the keychain if login failed.
					[keychain removeKeychainItem:account error:NULL];
				});
			}
			else
			{
				DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					[self setLoggedInUser:result];
				});
			}
		}];
	}
}

- (void)renewSessionIfNecessary
{
    // Only if the user is logged in check if the session is still valid.
    if (!self.loggedInUser)
	 {
		 return;
	 }
	 
	[self isSignedInWithCompletion:^(id result, NSError *error) {
		if (error)
		{
			if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == kCFURLErrorNotConnectedToInternet)
			{
				// no Internet
				return;
			}
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				NSDictionary *userInfo = @{@"Error": error};
				[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerLoginErrorNotification
																					 object:self
																				  userInfo:userInfo];
			});
		}
		else
		{
			if([result isEqualToString:@"true"]){
				// Nothing to do the session is valid.
			} else {
				// Renew the session.
				[self _loadState];
			}
		}
	}];
}

- (void)setLoggedInUser:(PLYUser *)loggedInUser
{
	[self willChangeValueForKey:@"loggedInUser"];
	_loggedInUser = loggedInUser;
	[self didChangeValueForKey:@"loggedInUser"];
}


#pragma mark - Search

/**
 * Search product by GTIN and language.
 **/
- (void)performSearchForGTIN:(NSString *)gtin language:(NSString *)language completion:(PLYCompletion)completion
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

/**
 * Search product by name and language.
 **/
- (void)performSearchForName:(NSString *)name language:(NSString *)language completion:(PLYCompletion)completion{
	NSParameterAssert(name);
	
	[self performSearchForProduct:nil
									 name:name
								language:language
								 orderBy:@"pl-prod-name_asc"
									 page:nil
						recordsPerPage:nil
							 completion:completion];
}

/**
 * Search for a product. If no search paramter are present the first 50 products will be presented.
 **/
- (void)performSearchForProduct:(NSString *)gtin
                           name:(NSString *)name
                       language:(NSString *)language
                        orderBy:(NSString *)orderBy
                           page:(NSNumber *)page
                 recordsPerPage:(NSNumber *)rpp
							completion:(PLYCompletion)completion
{
	NSString *path = [self _functionPathForFunction:@"products"];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (gtin)       [parameters setObject:gtin     forKey:@"gtin"];
	if (language)   [parameters setObject:language forKey:@"language"];
	if (name)       [parameters setObject:name     forKey:@"name"];
	if (orderBy)    [parameters setObject:orderBy  forKey:@"order_by"];
	if (page)       [parameters setObject:page     forKey:@"page"];
	if (rpp)        [parameters setObject:rpp      forKey:@"records_per_page"];
	
	[self _performMethodCallWithPath:path
								 parameters:parameters
								 completion:completion];
}

#pragma mark - Products

/**
 * Get all image metadata for a specific product. Use this to get all image URL's for the product.
 **/
- (void)getImagesForGTIN:(NSString *)gtin completion:(PLYCompletion)completion
{
	NSParameterAssert(gtin);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"product/%@/images", gtin];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path
								 parameters:nil
								 completion:completion];
}

/**
 * Get the localized category keys.
 **/
- (void) getCategoriesForLocale:(NSString *)language completion:(PLYCompletion)completion{
	NSParameterAssert(language);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/products/categories?language=%@", language];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path
								 parameters:nil
								 completion:completion];
}

#pragma mark - Managing Users

/**
 * Register a new user. Minimum information which must be provided is (nickname, email). A autogenerated password will be send to you via email.
 **/
- (void)createUserWithName:(NSString *)user email:(NSString *)email completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	NSParameterAssert(email);
	NSParameterAssert(completion);
	
	NSString *path = [self _functionPathForFunction:@"users"];
	
	NSDictionary *payloadDictionary = @{@"pl-usr-nickname": user, @"pl-usr-email": email};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:payloadDictionary completion:completion];
}

/**
 * Login the user with basic authentication.
 **/
- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	NSParameterAssert(password);
	NSParameterAssert(completion);
    
    _performingLogin = YES;
	
	NSString *path = [self _functionPathForFunction:@"login"];
	
    NSString *authValue = [self basicAuthenticationForUser:user andPassword:password];
	
	PLYCompletion wrappedCompletion = [completion copy];
	
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (!error && [result isKindOfClass:PLYUser.class])
		{
			[self setLoggedInUser:result];
			
			// Search for account in keychain.
			DTKeychain *keychain = [DTKeychain sharedInstance];
			DTKeychainGenericPassword *serviceAccount = [[keychain keychainItemsMatchingQuery:[DTKeychainGenericPassword keychainItemQueryForService:PLY_SERVICE account:user] error:NULL] lastObject];
			
			// create new account
			if (!serviceAccount)
			{
				serviceAccount = [DTKeychainGenericPassword new];
				serviceAccount.service = PLY_SERVICE;
				serviceAccount.account = user;
			}
			
			// always update password
			serviceAccount.password = password;
			
			// persist
			[keychain writeKeychainItem:serviceAccount error:NULL];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
        
        _performingLogin = NO;
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil basicAuth:authValue completion:ownCompletion];
}

- (NSString *) basicAuthenticationForUser:(NSString *)user andPassword:(NSString *)password{
	// Basic Authentication
	NSString *authStr = [NSString stringWithFormat:@"%@:%@", user, password];
	NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
	return [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
}

/**
 * Logout the current user.
 **/
- (void)logoutUserWithCompletion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
    
    // Remove account from keychain.
    if (_loggedInUser)
    {
		 DTKeychain *keychain = [DTKeychain sharedInstance];
		 
		 NSArray *accounts = [keychain keychainItemsMatchingQuery:[DTKeychainGenericPassword keychainItemQueryForService:PLY_SERVICE account:_loggedInUser.nickname] error:NULL];
		 [keychain removeKeychainItems:accounts error:NULL];
    }
	
	NSString *path = [self _functionPathForFunction:@"logout"];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil completion:completion];
    
	[self setLoggedInUser:nil];
}

/**
 * Check if user is signed in
 **/
- (void)isSignedInWithCompletion:(PLYCompletion)completion
{
    NSString *path = [self _functionPathForFunction:@"signedin"];
    
    
    [self _performMethodCallWithPath:path
                          parameters:nil
                          completion:completion];
}

/**
 * Generates a new password for the user. The password will be send to the users email.
 **/
- (void)requestNewPasswordForUserWithEmail:(NSString *)email
                                completion:(PLYCompletion)completion{
	NSParameterAssert(email);
	NSParameterAssert(completion);
	
	NSString *path = [self _functionPathForFunction:@"/user/lost_password"];
	
	NSDictionary *payload = [NSDictionary dictionaryWithObject:email forKey:@"email"];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:payload completion:completion];
}

/**
 Determines an image URL for the given PLYUser
  */
- (NSURL *)avatarImageURLForUser:(PLYUser *)user
{
	NSParameterAssert(user);
	NSAssert(user.Id, @"User needs to have an identifier to retrieve an avator URL");
	
	NSString *function = [NSString stringWithFormat:@"/user/%@/avatar", user.Id];
	NSString *path = [self _functionPathForFunction:function];

	return [self _methodURLForPath:path parameters:nil];
}

- (void)uploadAvatarImage:(DTImage *)image forUser:(PLYUser *)user completion:(PLYCompletion)completion
{
	NSParameterAssert(image);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/user/%@/avatar", user.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		// reset logged in user avatar URL
		if ([user.Id isEqualToString:self.loggedInUser.Id])
		{
			PLYUserAvatar *avatar = (PLYUserAvatar *)result;
			
			// update ID
			[self.loggedInUser setValue:avatar.Id forKey:@"avatarImageIdentifier"];
			
			// reset image URL, this triggers reloading of the image
			[self.loggedInUser setValue:[self avatarImageURLForUser:user] forKey:@"avatarURL"];
		}
		
		completion(result, error);
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:image completion:wrappedCompletion];
}

- (void)resetAvatarForUser:(PLYUser *)user completion:(PLYCompletion)completion
{
	NSString *function = [NSString stringWithFormat:@"/user/%@/avatar", user.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		// reset logged in user avatar URL
		if ([user.Id isEqualToString:self.loggedInUser.Id])
		{
			// remove the image ID to disable the delete option
			[self.loggedInUser setValue:nil forKey:@"avatarImageIdentifier"];
			
			// reset image URL, this triggers reloading of the image
			[self.loggedInUser setValue:[self avatarImageURLForUser:user] forKey:@"avatarURL"];
		}
		
		if (completion)
		{
			completion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil payload:nil completion:wrappedCompletion];
}

#pragma mark - Managing Products

/**
 * Creates a new product.
 * ATTENTION: Login required
 **/
- (void)createProductWithGTIN:(NSString *)gtin dictionary:(NSDictionary *)dictionary completion:(PLYCompletion)completion
{
	NSParameterAssert(gtin);
	NSParameterAssert(completion);
	
	NSString *path = [self _functionPathForFunction:@"products"];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:dictionary completion:completion];
}

/**
 * Update a specific product.
 * ATTENTION: Login required
 **/
- (void)updateProductWithGTIN:(NSString *)gtin dictionary:(NSDictionary *)dictionary completion:(PLYCompletion)completion
{
	NSParameterAssert(gtin);
	NSParameterAssert(dictionary);
	NSParameterAssert(completion);
	
	NSString *path = [self _functionPathForFunction:[NSString stringWithFormat:@"/product/%@",gtin]];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"PUT" parameters:nil payload:dictionary completion:completion];
}


#pragma mark - Working with Brands and Brand Owners

- (void)getRecommendedBrandOwnersForGTIN:(NSString *)GTIN
										completion:(PLYCompletion)completion
{
	NSParameterAssert(GTIN);
	NSParameterAssert(completion);
	
	NSString *path = [self _functionPathForFunction:[NSString stringWithFormat:@"/product/%@/recommended_brand_owners", GTIN]];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:nil completion:completion];
}


- (void)getBrandsWithCompletion:(PLYCompletion)completion
{
	NSString *path = [self _functionPathForFunction:[NSString stringWithFormat:@"/products/brands"]];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:nil completion:completion];
}


#pragma mark - Image Handling

/**
 * Get the metadata of the last uploaded images of all products.
 **/
- (void)getLastUploadedImagesWithPage:(NSInteger)page andRPP:(NSInteger)rpp completion:(PLYCompletion)completion{
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/images/last?page=%ld&records_per_page=%ld", (long)page, (long)rpp];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path
                          parameters:nil
                          completion:completion];
}

/**
 * Upload a image for a product.
 * ATTENTION: Login required
 **/
- (void)uploadImageData:(DTImage *)data forGTIN:(NSString *)gtin completion:(PLYCompletion)completion
{
	NSParameterAssert(gtin);
	NSParameterAssert(data);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"product/%@/images", gtin];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:data completion:completion];
}

#pragma mark - Opines

- (void) performSearchForOpineWithGTIN:(NSString *)gtin
                          withLanguage:(NSString *)language
                  fromUserWithNickname:(NSString *)nickname
                        showFiendsOnly:(BOOL *)showFiendsOnly
                               orderBy:(NSString *)orderBy
                                  page:(NSNumber *)page
                        recordsPerPage:(NSNumber *)rpp
                            completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function = @"opines";
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (gtin)           [parameters setObject:gtin     forKey:@"gtin"];
	if (language)       [parameters setObject:language forKey:@"language"];
	if (nickname)       [parameters setObject:nickname forKey:@"nickname"];
	
    if (showFiendsOnly) [parameters setObject:@"true"   forKey:@"show_fiends_only"];
    else                [parameters setObject:@"false"   forKey:@"show_fiends_only"];
	
    if (orderBy)        [parameters setObject:orderBy  forKey:@"order_by"];
	if (page)           [parameters setObject:page     forKey:@"page"];
	if (rpp)            [parameters setObject:rpp      forKey:@"records_per_page"];
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

- (void)createOpine:(PLYOpine *)opine
			completion:(PLYCompletion)completion
{
	NSParameterAssert(opine);
	NSParameterAssert(opine.text);
	NSParameterAssert(opine.GTIN);
	NSParameterAssert(opine.language);
	NSParameterAssert(completion);
	
	NSString *function = @"opines";
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:[opine dictionaryRepresentation] completion:completion];
}

#pragma mark - Reviews

/**
 * Search for reviews.
 **/
- (void) performSearchForReviewWithGTIN:(NSString *)gtin
                           withLanguage:(NSString *)language
                   fromUserWithNickname:(NSString *)nickname
                             withRating:(NSNumber *)rating
                                orderBy:(NSString *)orderBy
                                   page:(NSNumber *)page
                         recordsPerPage:(NSNumber *)rpp
                             completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
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
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

/**
 * Creates a new review for a product.
 * ATTENTION: Login required
 **/
- (void) createReviewForGTIN:(NSString *)gtin
						dictionary:(NSDictionary *)dictionary
						completion:(PLYCompletion)completion
{
	NSParameterAssert(gtin);
	NSParameterAssert(dictionary);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"product/%@/review",gtin];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:dictionary completion:completion];
}

#pragma mark - Lists

/**
 * Create a new product list for the authenticated user.
 * ATTENTION: Login required
 **/
- (void) createProductList:(PLYList *)list
                completion:(PLYCompletion)completion
{
	NSParameterAssert(list);
	NSParameterAssert(completion);
	
	NSString *function = @"lists";
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:[list dictionaryRepresentation] completion:completion];
}

/**
 * Request product lists for a specific user and type.
 * ATTENTION: Login required
 **/
- (void) performSearchForProductListFromUser:(PLYUser *)user
                                 andListType:(NSString *)listType
                                        page:(NSNumber *)page
                              recordsPerPage:(NSNumber *)rpp
                                  completion:(PLYCompletion)completion{
	
	NSParameterAssert(completion);
	
	NSString *function = @"lists";
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (user)       [parameters setObject:user.Id  forKey:@"user_id"];
	if (listType)   [parameters setObject:listType forKey:@"language"];
	if (page)       [parameters setObject:page     forKey:@"page"];
	if (rpp)        [parameters setObject:rpp      forKey:@"records_per_page"];
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

/**
 * Request a product list by id.
 * The product list can only be requested if the user is the owner, the list is shared with the user or if the list is public.
 * ATTENTION: Login required
 **/
- (void) getProductListWithId:(NSString *)listId
                   completion:(PLYCompletion)completion{
	NSParameterAssert(listId);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"list/%@", listId];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path parameters:nil completion:completion];
}

/**
 * Update a product list.
 * The product list can only be updated by the owner of the list.
 * ATTENTION: Login required
 **/
- (void) updateProductList:(PLYList *)list
                completion:(PLYCompletion)completion{
	NSParameterAssert(list);
	NSParameterAssert(list.Id);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"list/%@", list.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"PUT" parameters:nil payload:[list dictionaryRepresentation] completion:completion];
}

/**
 * Delete the product list with id.
 * The product list can only be deleted by the owner of the list.
 * ATTENTION: Login required
 **/
- (void) deleteProductListWithId:(NSString *)listId
                      completion:(PLYCompletion)completion{
	NSParameterAssert(listId);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"list/%@", listId];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil completion:completion];
}

#pragma mark List Items

/**
 * Replaces or add's the product to the list if it doesn't exist.
 * ATTENTION: Login required
 **/
- (void) addOrReplaceListItem:(PLYListItem *)listItem
                 toListWithId:(NSString *)listId
                   completion:(PLYCompletion)completion{
	NSParameterAssert(listItem);
	NSParameterAssert(listItem.GTIN);
	NSParameterAssert(listId);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"list/%@/product/%@", listId,listItem.GTIN];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"PUT" parameters:nil payload:[listItem dictionaryRepresentation] completion:completion];
}

/**
 * Delete a product from the list.
 * ATTENTION: Login required
 **/
- (void) deleteProductWithGTIN:(NSString *)gtin
					 fromListWithId:(NSString *)listId
						  completion:(PLYCompletion)completion{
	NSParameterAssert(gtin);
	NSParameterAssert(listId);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"list/%@/product/%@", listId,gtin];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil completion:completion];
}

#pragma mark List Sharing

/**
 * Share the list with a user.
 * ATTENTION: Login required
 **/
- (void) shareProductListWithId:(NSString *)listId
                     withUserId:(NSString *)userId
                     completion:(PLYCompletion)completion{
	NSParameterAssert(userId);
	NSParameterAssert(listId);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"list/%@/share/%@", listId,userId];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil completion:completion];
}

/**
 * Unshare the list with a user.
 * ATTENTION: Login required
 **/
- (void) unshareProductListWithId:(NSString *)listId
                       withUserId:(NSString *)userId
                       completion:(PLYCompletion)completion{
	NSParameterAssert(userId);
	NSParameterAssert(listId);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"list/%@/share/%@", listId,userId];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil completion:completion];
}

#pragma mark - Users
/**
 * Search for a user with a simple text search.
 * The searchText can contain the email, nickname, first name and last name of the user.
 **/
- (void) performUserSearch:(NSString *)searchText
                completion:(PLYCompletion)completion
{
	NSParameterAssert(searchText);
	NSParameterAssert(completion);
	
	NSString *function = @"users";
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (searchText)       [parameters setObject:searchText     forKey:@"query"];
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

/**
 * Returns the follower from a specific user.
 * ATTENTION: Login required
 **/
- (void) getFollowerFromUser:(NSString *)nickname
                        page:(NSNumber *)page
              recordsPerPage:(NSNumber *)rpp
                  completion:(PLYCompletion)completion{
	NSParameterAssert(nickname);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"user/%@/follower", nickname];
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (page)       [parameters setObject:page     forKey:@"page"];
	if (rpp)        [parameters setObject:rpp      forKey:@"records_per_page"];
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

/**
 * Returns the followed users by the specific user.
 * ATTENTION: Login required
 **/
- (void) getFollowingFromUser:(NSString *)nickname
                         page:(NSNumber *)page
               recordsPerPage:(NSNumber *)rpp
						 completion:(PLYCompletion)completion{
	NSParameterAssert(nickname);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"user/%@/following", nickname];
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (page)       [parameters setObject:page     forKey:@"page"];
	if (rpp)        [parameters setObject:rpp      forKey:@"records_per_page"];
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

/**
 * Follow a specific user.
 * ATTENTION: Login required
 **/
- (void) followUserWithNickname:(NSString *)nickname
                     completion:(PLYCompletion)completion{
	NSParameterAssert(nickname);
	NSParameterAssert(completion);
	
	NSString *function = @"/user/follow";
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (nickname)   [parameters setObject:nickname forKey:@"nickname"];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:parameters completion:completion];
}

/**
 * Unfollow a specific user.
 * ATTENTION: Login required
 **/
- (void) unfollowUserWithNickname:(NSString *)nickname
                       completion:(PLYCompletion)completion{
	NSParameterAssert(nickname);
	NSParameterAssert(completion);
	
	NSString *function = @"/user/unfollow";
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (nickname)   [parameters setObject:nickname forKey:@"nickname"];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:parameters completion:completion];
}

/**
 * Get specific user with nickname.
 **/
- (void)  getUserByNickname:(NSString *)nickname
                 completion:(PLYCompletion)completion{
	NSParameterAssert(nickname);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/user/%@", nickname];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path parameters:nil completion:completion];
}

#pragma mark - Timelines

- (void)timelineForAllUsersWithCount:(NSNumber *)count completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	[self timelineForAllUsersWithCount:count
                               sinceID:nil
                               untilID:nil
                            showOpines:true
                           showReviews:true
                            showImages:true
                          showProducts:true
                            completion:completion];
}

- (void)timelineForAllUsersWithCount:(NSNumber *)count
                             sinceID:(NSString *)sinceID
                             untilID:(NSString *)untilID
                          showOpines:(BOOL)showOpines
                         showReviews:(BOOL)showReviews
                          showImages:(BOOL)showImages
                        showProducts:(BOOL)showProducts
                          completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function = @"/timeline";
	NSString *path = [self _functionPathForFunction:function];
    
    NSMutableDictionary *params = [self createTimelineParameterWithSinceID:sinceID
                                                                   untilID:untilID
                                                                     count:count
                                                                showOpines:showOpines
                                                               showReviews:showReviews
                                                                showImages:showImages
                                                              showProducts:showProducts];
	
	[self _performMethodCallWithPath:path parameters:params completion:completion];
}

- (void)timelineForMeWithCount:(NSNumber *)count
                             sinceID:(NSString *)sinceID
                             untilID:(NSString *)untilID
                          showOpines:(BOOL)showOpines
                         showReviews:(BOOL)showReviews
                          showImages:(BOOL)showImages
                        showProducts:(BOOL)showProducts
                          completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function = @"/timeline/me";
	NSString *path = [self _functionPathForFunction:function];
    
    NSMutableDictionary *params = [self createTimelineParameterWithSinceID:sinceID
                                                                   untilID:untilID
                                                                     count:count
                                                                showOpines:showOpines
                                                               showReviews:showReviews
                                                                showImages:showImages
                                                              showProducts:showProducts];
	
	[self _performMethodCallWithPath:path parameters:params completion:completion];
}

- (void)timelineForUser:(NSString *)nickname
                sinceID:(NSString *)sinceID
                untilID:(NSString *)untilID
                  count:(NSNumber *)count
             showOpines:(BOOL)showOpines
            showReviews:(BOOL)showReviews
             showImages:(BOOL)showImages
           showProducts:(BOOL)showProducts
             completion:(PLYCompletion)completion
{
    NSParameterAssert(nickname);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/timeline/user/%@", nickname];
	NSString *path = [self _functionPathForFunction:function];
    
    NSMutableDictionary *params = [self createTimelineParameterWithSinceID:sinceID
                                                                   untilID:untilID
                                                                     count:count
                                                                showOpines:showOpines
                                                               showReviews:showReviews
                                                                showImages:showImages
                                                              showProducts:showProducts];
	
	[self _performMethodCallWithPath:path parameters:params completion:completion];
}

- (void)timelineForProduct:(NSString *)GTIN
                   sinceID:(NSString *)sinceID
                   untilID:(NSString *)untilID
                     count:(NSNumber *)count
                showOpines:(BOOL)showOpines
               showReviews:(BOOL)showReviews
                showImages:(BOOL)showImages
              showProducts:(BOOL)showProducts
                completion:(PLYCompletion)completion
{
    NSParameterAssert(GTIN);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/timeline/product/%@", GTIN];
	NSString *path = [self _functionPathForFunction:function];
    
    NSMutableDictionary *params = [self createTimelineParameterWithSinceID:sinceID
                                                                   untilID:untilID
                                                                     count:count
                                                                showOpines:showOpines
                                                               showReviews:showReviews
                                                                showImages:showImages
                                                              showProducts:showProducts];
	
	[self _performMethodCallWithPath:path parameters:params completion:completion];
}

- (NSMutableDictionary *) createTimelineParameterWithSinceID:(NSString *)sinceID
                                                     untilID:(NSString *)untilID
                                                       count:(NSNumber *)count
                                                  showOpines:(BOOL)showOpines
                                                 showReviews:(BOOL)showReviews
                                                  showImages:(BOOL)showImages
                                                showProducts:(BOOL)showProducts
{
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
    
    if (sinceID)            [tmp setObject:sinceID forKey:@"since_id"];
    if (untilID)            [tmp setObject:untilID forKey:@"until_id"];
    if (count && count > 0) [tmp setObject:count forKey:@"count"];
    
    [tmp setObject:((showOpines)   ? @"true" : @"false") forKey:@"opines"];
    [tmp setObject:((showReviews)  ? @"true" : @"false") forKey:@"reviews"];
    [tmp setObject:((showImages)   ? @"true" : @"false") forKey:@"images"];
    [tmp setObject:((showProducts) ? @"true" : @"false") forKey:@"products"];
    
    return tmp;
}

#pragma mark - Votings

- (void)upVote:(PLYVotableEntity *)voteableEntity
    completion:(PLYCompletion)completion{
    
	NSParameterAssert(voteableEntity);
	NSParameterAssert(completion);
    
    NSString *function;
    if([voteableEntity isKindOfClass:[PLYImage class]]){
        function = [NSString stringWithFormat:@"image/%@/up_vote", [(PLYImage *)voteableEntity fileId]];
    } else if ([voteableEntity isKindOfClass:[PLYProduct class]]){
        function = [NSString stringWithFormat:@"product/%@/up_vote", [voteableEntity Id]];
    } else if ([voteableEntity isKindOfClass:[PLYOpine class]]){
        function = [NSString stringWithFormat:@"opine/%@/up_vote", [voteableEntity Id]];
    } else if ([voteableEntity isKindOfClass:[PLYReview class]]){
        function = [NSString stringWithFormat:@"review/%@/up_vote", [voteableEntity Id]];
    } else {
        NSAssert(false, @"Can't vote this entity.");
    }
    
    NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil completion:completion];
}

- (void)downVote:(PLYVotableEntity *)voteableEntity
      completion:(PLYCompletion)completion{
    
    NSParameterAssert(voteableEntity);
	NSParameterAssert(completion);
    
    NSString *function;
    if([voteableEntity isKindOfClass:[PLYImage class]]){
        function = [NSString stringWithFormat:@"image/%@/down_vote", [(PLYImage *)voteableEntity fileId]];
    } else if ([voteableEntity isKindOfClass:[PLYProduct class]]){
        function = [NSString stringWithFormat:@"product/%@/down_vote", [voteableEntity Id]];
    } else if ([voteableEntity isKindOfClass:[PLYOpine class]]){
        function = [NSString stringWithFormat:@"opine/%@/down_vote", [voteableEntity Id]];
    } else if ([voteableEntity isKindOfClass:[PLYReview class]]){
        function = [NSString stringWithFormat:@"review/%@/down_vote", [voteableEntity Id]];
    } else {
        NSAssert(false, @"Can't vote this entity.");
    }
    
    NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil completion:completion];
}


#pragma mark - Properties

// lazy initializer for URL session
- (NSURLSession *)session {
	if (!_session) {
        // Set save cookies policy
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        
		_session = [NSURLSession sessionWithConfiguration:_configuration];
	}
	
	return _session;
}

@end
