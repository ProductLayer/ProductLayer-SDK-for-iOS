//
//  PLYServer.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "AppSettings.h"
#import "ProductLayer.h"

#import "DTLog.h"
#import "NSString+DTURLEncoding.h"
#import "DTBlockFunctions.h"
#import "AccountManager.h"

#if TARGET_OS_IPHONE
#import "UIApplication+DTNetworkActivity.h"
#endif

#define URLENC(string) [string \
stringByAddingPercentEncodingWithAllowedCharacters:\
[NSCharacterSet URLQueryAllowedCharacterSet]];

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
		
		for (NSString *key in sortedKeys) {
			NSString *value = parameters[key];
			
			// URL-encode
			NSString *encKey = URLENC(key);
			if([value isKindOfClass:[NSString class]]){
				value = URLENC(value);
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
	if (basicAuth){
		[request setValue:basicAuth forHTTPHeaderField:@"Authorization"];
	}
   
	
	// Add the api key to each request.
   NSAssert(_APIKey, @"Setting an API Key is required to perform requests. Use [[PLYServer sharedServer] setAPIKey:]");
	[request setValue:_APIKey forHTTPHeaderField:@"API-KEY"];
	
	NSMutableString *debugMessage = [NSMutableString string];
	[debugMessage appendFormat:@"%@ %@\n", request.HTTPMethod, [methodURL absoluteString]];
	
	// add body if set
	if (payload)
	{
		if ([payload isKindOfClass:[UIImage class]])
		{
			NSString *stringBoundary = @"0xKhTmLbOuNdArY---This_Is_ThE_BoUnDaRyy---pqo";
			
			// header value
			NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", stringBoundary];
			
			// set header
			[request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
			
			//NSData *imageData = (NSData *)_payload;
			NSData *tmpPayload = UIImageJPEGRepresentation(payload, 0.8);
			//NSData *base64Data = [tmpPayload base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength | NSDataBase64EncodingEndLineWithCarriageReturn];
			
			NSMutableData *postBody = [NSMutableData data];
			
			// media part
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"dummy.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Type: image/jpeg; name=dummy.jpg\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-ID: file\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			
			[postBody appendData:[NSData dataWithData:tmpPayload]];
			[postBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			// final boundary
			[postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			
			request.HTTPBody = postBody;
			
			// set the content-length
			NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postBody length]];
			[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
			
			request.timeoutInterval = 60;
		}
		else if ([payload isKindOfClass:[NSData class]])
		{
			NSString *stringBoundary = @"----=_Part_15_1001769400.1389805800711";
			
			// header value
			NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
			
			// set header
			[request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
			
			//NSData *imageData = (NSData *)_payload;
			NSData *base64Data = [payload base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength | NSDataBase64EncodingEndLineWithCarriageReturn];
			
			//NSData *base64Data = UIImageJPEGRepresentation(_payload, 1.0);
			
			NSMutableData *postBody = [NSMutableData data];
			
			// media part
			[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"dummy.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-ID: attachment\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[postBody appendData:[@"Content-Transfer-Encoding: base64\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			
			[postBody appendData:base64Data];
			[postBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
			
			
			// final boundary
			[postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
			
			request.HTTPBody = postBody;
			
			// set the content-length
			NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postBody length]];
			[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
			
			request.timeoutInterval = 60;
		}
		else if ([NSJSONSerialization isValidJSONObject:payload])
		{
			[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			
			NSData *payloadData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:NULL];
			[request setHTTPBody:payloadData];
			
			NSString *payloadString = [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
			[debugMessage appendString:payloadString];
		}
	}
	
	[self startDataTaskForRequest:request completion:completion];
	
}

- (void) startDataTaskForRequest:(NSMutableURLRequest *)request completion:(PLYCompletion)completion{
	
	NSURLSessionDataTask *task = [[self session]
											dataTaskWithRequest:request
											completionHandler:^(NSData *data,
																	  NSURLResponse *response,
																	  NSError *error) {
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
												
												if (!error && !ignoreContent)
												{
													id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
													
													// Try to parse the json object
													if([jsonObject isKindOfClass:[NSArray class]] && [jsonObject count] != 0){
														NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:1];
														
														for (NSDictionary *dictObject in jsonObject)
														{
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
    // Load login data from keychain
    NSArray *accounts = [[AccountManager sharedAccountManager] accountsForService:PLY_SERVICE];
    
    if(accounts && [accounts count] == 1){
        
        GenericAccount *account = [accounts objectAtIndex:0];
        
        if(account) {
            [self loginWithUser:account.account password:account.password completion:^(id result, NSError *error) {
                
                if (error)
                {
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed." message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                        [alert show];
                        
                        // Delete account from the keychain if login failed.
                        [[AccountManager sharedAccountManager] deleteGenericAccount:account];
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
    } else if(accounts && [accounts count] > 1){
        // There should be only one account for productlayer for security reasons delete all accounts
        for(GenericAccount *account in accounts){
            [[AccountManager sharedAccountManager] delete:account];
        }
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
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Check session state failed" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
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
	_loggedInUser = loggedInUser;
	[[NSNotificationCenter defaultCenter] postNotificationName:PLYNotifyUserStatusChanged object:self];
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
            GenericAccount *account = [[AccountManager sharedAccountManager] loadGenericAccountForService:PLY_SERVICE forAccount:user];
            
            if(!account) {
                // Create new account if no existing account have been found.
                account = [[AccountManager sharedAccountManager] createGenericAccountForService:PLY_SERVICE forAccount:user];
            }
            [account setPassword:password];
            
            // Save account into keychain
            [[AccountManager sharedAccountManager] saveGenericAccount:account];
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
    if(_loggedInUser)
    {
        [[AccountManager sharedAccountManager] deleteGenericAccount:_loggedInUser.nickname andService:PLY_SERVICE];
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
- (void)uploadImageData:(UIImage *)data forGTIN:(NSString *)gtin completion:(PLYCompletion)completion
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
	
	PLYOpine *sendingOpine = [opine copy];
	
	// only the reference to the entity is needed, so we reduce it
	if (sendingOpine.parent)
	{
		PLYVotableEntity *reducedParent = [[PLYVotableEntity alloc] init];
		reducedParent.Class = opine.parent.Class;
		reducedParent.Id = opine.parent.Id;
		[sendingOpine setParent:reducedParent];
	}
	
	NSString *function = @"opines";
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:[sendingOpine dictionaryRepresentation] completion:completion];
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
 * Get the avatar of an specific user with nickname.
 **/
- (void) getAvatarImageUrlFromUser:(PLYUser *)user
								completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	NSParameterAssert(completion);
	
	NSURL *url = nil;
	
	if (user.avatarURL)
	{
		url = user.avatarURL;
	}
	else if(user.nickname)
	{
		NSString *function = [NSString stringWithFormat:@"user/%@/avatar", user.nickname];
		NSString *path = [self _functionPathForFunction:function];
		
		url = [NSURL URLWithString:path relativeToURL:_hostURL];
	}
	
	completion(url, nil);
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
