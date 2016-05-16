//
//  PLYServer.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

@import DTFoundation;

#import "ProductLayerSDK.h"

#import "DTKeychain.h"
#import "DTKeychainGenericPassword.h"


#if TARGET_OS_IPHONE

#import "PLYLoginViewController.h"

#endif

#import <ProductLayerSDK/ProductLayerSDK-Swift.h>


// this is the URL for the endpoint server
#define PLY_ENDPOINT_URL [NSURL URLWithString:@"https://api.productlayer.com"]

// this is a prefix added before REST methods, e.g. for a version of the API
#define PLY_PATH_PREFIX @"0.5"

@interface PLYServer () <NSCacheDelegate>

@property (nonatomic, readwrite, strong) PLYUser *loggedInUser;

@end


@implementation PLYServer
{
	NSURL *_hostURL;
	NSString *_APIKey;
	NSString *_authToken;
	
	NSURLSession *_session;
	NSURLSessionConfiguration *_configuration;
	
	NSCache *_entityCache;
	
	// cached categories for the user main language
	NSDictionary *_categories;
    
    PLYCategoryManager *_categoryManager;
}

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
	self = [super init];
	
	if (self)
	{
		_hostURL = PLY_ENDPOINT_URL;
		_configuration = configuration;
		
		_entityCache = [[NSCache alloc] init];
		_entityCache.delegate = self;
		
		// load last state (login user)
		[self _loadState];
		
#if TARGET_OS_IPHONE
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_localeDidChange:) name:NSCurrentLocaleDidChangeNotification object:nil];
#endif
	}
	
	return self;
}

// designated initializer
- (instancetype)init
{
	_performingLogin = NO;
	
	// use default config, we need credential & caching
	NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    _categoryManager = [PLYCategoryManager new];
	
	return [self initWithSessionConfiguration:config];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
	DTLogDebug(@"evict: %@ with ID %@", obj, [obj Id]);
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
	
	// try to update details (like score for logged in user)
	if (_loggedInUser)
	{
		[self loadDetailsForUser:_loggedInUser completion:^(id result, NSError *error) {
			if (error)
			{
				DTLogError(@"Error updating details for logged in user: %@", [error localizedDescription]);
				return;
			}
		}];
	}
	
	[self _refreshCategories];
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
			if([value isKindOfClass:[NSString class]])
			{
				value = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
			}
			
			// combine into pairs
			NSString *tmpStr = [NSString stringWithFormat:@"%@=%@",
									  key, value];
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
	
	// Add preferred languages
	NSString *languages = [[NSLocale preferredLanguages] componentsJoinedByString:@", "];
	[request setValue:languages forHTTPHeaderField:@"Accept-Language"];
    
    // accept gzip
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	// add auth token if present
	if (_authToken)
	{
		[request setValue:_authToken forHTTPHeaderField:@"X-ProductLayer-Auth-Token"];
	}
	
	if ([path hasSuffix:@"/categories"])
	{
		NSString *lang = [[NSLocale preferredLanguages] firstObject];
		NSString *key = [NSString stringWithFormat:@"%@-Last-Modified-%@", methodURL.absoluteString, lang];
		NSString *lastModified = [[NSUserDefaults standardUserDefaults] objectForKey:key];
		
		if (lastModified)
		{
			[request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
		}
	}
	
	// add body if set
	if (payload)
	{
		NSData *payloadData;
		
		if ([payload isKindOfClass:[DTImage class]])
		{
			payloadData = DTImageJPEGRepresentation(payload, 0.81);
			[request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
			request.timeoutInterval = 60;
		}
		else if ([payload isKindOfClass:[NSData class]])
		{
			payloadData = [payload copy];
			
			// workaround for generic data upload for image
			if ([path containsString:@"image"])
			{
				[request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
			}
			else
			{
				[request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
			}
			
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

- (void)_updateAuthTokenFromHeaders:(NSDictionary *)headers
{
	NSArray *cookies = [headers[@"Set-Cookie"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",;"]];
	
	NSString *authHeaderName = @"X-ProductLayer-Auth-Token";
	for (NSString *oneCookie in cookies)
	{
		if ([oneCookie hasPrefix:authHeaderName])
		{
			_authToken = [oneCookie substringFromIndex:[authHeaderName length]+1];
		}
	}
}

- (void)_checkNewAchievementsFromHeaders:(NSDictionary *)headers extraAchievement:(PLYAchievement *)achievement
{
    NSString *header = headers[@"X-ProductLayer-User-Unlocked-Achievements"];

    if (!header && !achievement)
    {
        return;
    }
    
    header = [header stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
    
    
    NSArray *keys = [header componentsSeparatedByString:@","];
    
    DTLogInfo(@"New achievements: %@", header);
    
    // collect the achievements info in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_semaphore_t sema =  dispatch_semaphore_create(0);
        
        NSMutableArray *achievements = [NSMutableArray array];
        
        if (achievement)
        {
            [achievements addObject:achievement];
        }
        
        for (NSString *oneKey in keys)
        {
            NSString *defaultsKey = [self.loggedInUser.Id stringByAppendingString: oneKey];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            if ([defaults boolForKey:defaultsKey])
            {
                // already notified for this achievement
               // continue;
            }
            
            [defaults setBool:YES forKey:defaultsKey];
            
            [self achievementForKey:oneKey completion:^(id result, NSError *error) {
                
                if (error)
                {
                    DTLogError(@"Cannot get achievement for key '%@': %@", oneKey, [error localizedDescription]);
                }
                else if ([result isKindOfClass:[PLYAchievement class]])
                {
                    [achievements addObject:result];
                }
                
                dispatch_semaphore_signal(sema);
            }];
            
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
        
        // now we collected all infos, send notification
        
        if ([achievements count])
        {
            NSDictionary *userInfo = @{PLYServerAchievementKey: [achievements copy]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:PLYServerNewAchievementNotification object:self userInfo:userInfo];
        }
    });
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
												if (retError)
												{
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
												
												if (statusCode == 403)
												{
													[self _loadState];
												}
												else if (statusCode < 400)
												{
													[self _updateAuthTokenFromHeaders:headers];
													
													NSString *lastModified = headers[@"Last-Modified"];
													
													if (lastModified)
													{
														NSString *lang = [[NSLocale preferredLanguages] firstObject];
														NSString *key = [NSString stringWithFormat:@"%@-Last-Modified-%@", request.URL.absoluteString, lang];
														[[NSUserDefaults standardUserDefaults] setObject:lastModified forKey:key];
													}
												}
												
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
													}
													else if ([contentType hasPrefix:@"text/html"])
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
                                                    NSUInteger oldPoints = user.points;
                                                    NSUInteger oldLevel = PLYLevelForPoints(oldPoints);
                                                    
													if (pointsNum)
                                                    {
                                                        [user setValue:pointsNum forKey:@"points"];
                                                    }
                                                    
                                                    NSUInteger newLevel = PLYLevelForPoints(user.points);
                                                    
                                                    PLYLevelUpAchievement *extraAchievement = nil;
                                                    
                                                    NSNumber *levelNum = headers[@"X-ProductLayer-User-Level-Changed"];
                                                    
                                                    if (levelNum || newLevel > oldLevel)
                                                    {
                                                        extraAchievement = [PLYLevelUpAchievement new];
                                                        extraAchievement.key = [NSString stringWithFormat:@"level-%ld", (unsigned long)newLevel];
                                                        extraAchievement.pointsBeforeLevelUp = oldPoints;
                                                        extraAchievement.pointsAfterLevelUp = user.points;
                                                    }
                                                    
                                                    [self _checkNewAchievementsFromHeaders:headers extraAchievement:extraAchievement];
                                                }
                                                
												if (!error && !ignoreContent)
												{
													id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
													
													// Try to parse the json object
													if ([jsonObject isKindOfClass:[NSArray class]])
													{
														NSMutableArray *objectArray = [NSMutableArray arrayWithCapacity:1];
														
														for (NSDictionary *dictObject in jsonObject)
														{
															if ([dictObject isKindOfClass:[NSDictionary class]])
															{
																id object = [PLYEntity entityFromDictionary:dictObject];
																
																if (object)
																{
																	[objectArray addObject:object];
																}
																
																continue;
															}
															
															// cannot be an entity, just add it
															[objectArray addObject:dictObject];
														}
														
														// result is converted objects
														result = [objectArray copy];
													}
													else if ([jsonObject isKindOfClass:[NSDictionary class]])
													{
														// result is one converted object
														result = [PLYEntity entityFromDictionary:jsonObject];
														
														// in some occasions we get back a dictionary that is no JSON object, e.g. categories
														if (!result)
														{
															result = jsonObject;
														}
													}
												}
												
												if (statusCode >= 400)
												{
													if ([result isKindOfClass:[PLYErrorResponse class]])
													{
														// pick out first of potentially multiple errors
														PLYErrorResponse *errorResponse = (PLYErrorResponse *)result;
														PLYErrorMessage *firstError = [errorResponse.errors firstObject];
														NSString *message = firstError.message;
														
														retError = [self _errorWithCode:statusCode message:message];
													}
													else
													{
														if ((statusCode == 404 || statusCode >= 500) && [contentType isEqualToString:@"text/html"])
														{
															retError = [self _errorWithCode:statusCode message:@"ProductLayer API currently not available. Please try again later."];
														}
														else
														{
															// construct new error for the status code
															retError = [self _errorWithCode:statusCode
																							message:[NSHTTPURLResponse localizedStringForStatusCode:(NSInteger)statusCode]];
														}
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
		
		[tmpQuery appendString:key];
		
		[tmpQuery appendString:@"="];
		
		NSString *encoded = [[obj description] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
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
	@synchronized(self)
	{
		NSString *path = [[NSString cachesPath] stringByAppendingPathComponent:@"loggedInUser.plist"];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:path])
		{
			DTLogInfo(@"No loggedInUser plist found");
			
			return;
		}
		
		// load user from cache file
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
		PLYUser *loggedInUser = [[PLYUser alloc] initWithDictionary:dict];
		
		
		if (!loggedInUser || !loggedInUser.Id || !loggedInUser.nickname)
		{
			DTLogInfo(@"No user logged in");
			
			return;
		}
		
		// replace with entity from cache if it exists
		loggedInUser = [self _entityByUpdatingCachedEntity:loggedInUser];
		
		// get auth token from keychain for this user
		DTKeychain *keychain = [DTKeychain sharedInstance];
		
		NSError *error;
		NSArray *serviceAccounts = [keychain keychainItemsMatchingQuery:[DTKeychainGenericPassword keychainItemQueryForService:PLY_SERVICE account:loggedInUser.Id] error:&error];
		
		if (!serviceAccounts)
		{
			DTLogError(@"Error retrieving keychain item: %@", [error localizedDescription]);
			return;
		}
		
		DTKeychainGenericPassword *account = [serviceAccounts firstObject];
		
		if (!account)
		{
			DTLogError(@"No token found in keychain");
			return;
		}
		
		_authToken = account.password;
		self.loggedInUser = loggedInUser;
	}
}

- (void)_saveState
{
	@synchronized(self)
	{
		NSString *path = [[NSString cachesPath] stringByAppendingPathComponent:@"loggedInUser.plist"];
		
		if (!_loggedInUser || !_authToken)
		{
			DTLogInfo(@"Removing logged in user and keychain item");
			
			// delete the logged in user cache
			[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
			
			// remove all tokens from keychain
			DTKeychain *keychain = [DTKeychain sharedInstance];
			NSArray *serviceAccounts = [keychain keychainItemsMatchingQuery:[DTKeychainGenericPassword keychainItemQueryForService:PLY_SERVICE account:nil] error:NULL];
			
			for (DTKeychainItem *item in serviceAccounts)
			{
				[keychain removeKeychainItem:item error:NULL];
			}
			
			return;
		}
		
		NSDictionary *dict = [_loggedInUser dictionaryRepresentation];
		[dict writeToFile:path atomically:YES];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:path])
		{
			DTLogError(@"An error occurred persisting %@", dict);
			
			return;
		}
		
		// Search for account in keychain.
		DTKeychain *keychain = [DTKeychain sharedInstance];
		
		NSError *error;
		NSArray *serviceAccounts = [keychain keychainItemsMatchingQuery:[DTKeychainGenericPassword keychainItemQueryForService:PLY_SERVICE account:_loggedInUser.Id] error:&error];
		
		// create new account
		if (error)
		{
			DTLogError(@"Error querying keychain: %@", [error localizedDescription]);
			return;
		}
		
		DTKeychainGenericPassword *account = [serviceAccounts lastObject];
		
		if (!account)
		{
			// need to make a new one
			account = [DTKeychainGenericPassword new];
			account.service = PLY_SERVICE;
			account.account = _loggedInUser.Id;
		}
		
		// always update password
		account.password = _authToken;
		
		NSDictionary *userDict = [_loggedInUser dictionaryRepresentation];
		NSData *data = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:NULL];
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		account.descriptionText = jsonString;
		
		// persist
		if (![keychain writeKeychainItem:account error:&error])
		{
			DTLogError(@"Error creating keychain entry: %@", [error localizedDescription]);
		};
	}
}

- (void)_invalidateAuthToken
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		// remove logged in user
		self.loggedInUser = nil;
		
		// update the persisted state
		[self _saveState];
	});
}

#pragma mark - Helpers

- (void)_clearSession
{
    _authToken = nil;
    _loggedInUser = nil;
    
    // delete all cookies to prevent any from tainting a new session
    for (NSHTTPCookie *cookie in _configuration.HTTPCookieStorage.cookies)
    {
        [_configuration.HTTPCookieStorage deleteCookie:cookie];
    }
}

- (NSDictionary *)_dictionaryRepresentationWithoutReadOnlyProperties:(PLYEntity *)entity
{
	NSMutableDictionary *tmpDict = [[entity dictionaryRepresentation] mutableCopy];
	
	// remove read-only properties
	[tmpDict removeObjectForKey:@"pl-prod-review-count"];
	[tmpDict removeObjectForKey:@"pl-prod-review-rating"];
	[tmpDict removeObjectForKey:@"pl-upd-by"];
	[tmpDict removeObjectForKey:@"pl-upd-time"];
	[tmpDict removeObjectForKey:@"pl-created-by"];
	[tmpDict removeObjectForKey:@"pl-created-time"];
	[tmpDict removeObjectForKey:@"pl-version"];
	[tmpDict removeObjectForKey:@"pl-vote-score"];
	
	return [tmpDict copy];
}

// return a cached updated version of the entity, or cache the entity if there was no cached version
- (id)_entityByUpdatingCachedEntity:(PLYEntity *)entity
{
	NSAssert([entity isKindOfClass:[PLYEntity class]], @"Incorrect parameter for %s", __PRETTY_FUNCTION__);
	
	PLYEntity *cachedEntity = [_entityCache objectForKey:entity.Id];
	
	if (cachedEntity)
	{
		if (cachedEntity == entity)
		{
			// cannot update from myself
			return entity;
		}
		
		// only update if the new entity is not a stub
		if (entity.Class && entity.version >= cachedEntity.version)
		{
			[cachedEntity updateFromEntity:entity];
			
			// changes to logged in user needs to be persisted
			if (cachedEntity == _loggedInUser)
			{
				[self _saveState];
			}
		}
		
		entity = cachedEntity;
	}
	else
	{
		// cache it
		[_entityCache setObject:entity forKey:entity.Id];
	}
	
	return entity;
}

- (NSArray *)_arrayOfUpdatedCachedEntities:(NSArray *)array
{
	NSAssert([array isKindOfClass:[NSArray class]], @"Incorrect parameter for %s", __PRETTY_FUNCTION__);
	
	NSMutableArray *tmpArray = [NSMutableArray array];
	
	// update user entities with cached versions
	for (PLYEntity *entity in array)
	{
		PLYEntity *cachedEntity = [self _entityByUpdatingCachedEntity:entity];
		[tmpArray addObject:cachedEntity];
		
		if ([cachedEntity isKindOfClass:[PLYEntity class]])
		{
			if (cachedEntity.createdBy && ![cachedEntity isEqual:cachedEntity.createdBy])
			{
				cachedEntity.createdBy = [self _entityByUpdatingCachedEntity:cachedEntity.createdBy];
			}
			
			if (cachedEntity.updatedBy && ![cachedEntity isEqual:cachedEntity.updatedBy])
			{
				cachedEntity.updatedBy = [self _entityByUpdatingCachedEntity:cachedEntity.updatedBy];
			}
		}
		
		// replace products with cached versions
		if ([cachedEntity isKindOfClass:[PLYOpine class]])
		{
			PLYOpine *opine = (PLYOpine *)cachedEntity;
			
			if (opine.product)
			{
				opine.product = [self _entityByUpdatingCachedEntity:opine.product];
			}
		}
	}
	
	return [tmpArray copy];
}

#pragma mark - Search

- (void)_refreshProductsWithGTIN:(NSString *)GTIN
{
	[self performSearchForGTIN:GTIN language:nil completion:^(id result, NSError *error) {
		
		if (error)
		{
			return;
		}
		
		for (PLYProduct *product in result)
		{
			PLYProduct *cachedProduct = [_entityCache objectForKey:product.Id];
			NSUInteger cachedVersion = cachedProduct.version;
			
			PLYProduct *updatedProduct = [self _entityByUpdatingCachedEntity:product];
			if (updatedProduct.version > cachedVersion)
			{
				NSDictionary *userInfo = @{PLYServerDidUpdateEntityKey: updatedProduct};
				[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidUpdateEntityNotification object:self userInfo:userInfo];
			}
		}
	}];
}

/**
 * Search product by GTIN and language.
 **/
- (void)performSearchForGTIN:(NSString *)gtin language:(NSString *)language completion:(PLYCompletion)completion
{
	NSParameterAssert(gtin);
	
	PLYCompletion wrappedCompletion = [completion copy];
	
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (!error)
		{
			if ([result isKindOfClass:[PLYEntity class]])
			{
				result = @[result];
			}
			
			for (PLYVotableEntity *entity in result)
			{
				// replace upvoters with cached entities
				NSMutableArray *tmpUpArray = [NSMutableArray array];
				
				for (PLYUser *user in entity.upVoter)
				{
					PLYUser *updatedUser = [self _entityByUpdatingCachedEntity:user];
					[tmpUpArray addObject:updatedUser];
				}
				
				entity.upVoter = [tmpUpArray copy];
				
				// replaces downvoters with cached entities
				NSMutableArray *tmpDownArray = [NSMutableArray array];
				
				for (PLYUser *user in entity.downVoter)
				{
					PLYUser *updatedUser = [self _entityByUpdatingCachedEntity:user];
					[tmpDownArray addObject:updatedUser];
				}
				
				entity.downVoter = [tmpDownArray copy];
				
				// update createdBy
				if (entity.createdBy)
				{
					entity.createdBy = [self _entityByUpdatingCachedEntity:entity.createdBy];
				}
			}
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
		
		_performingLogin = NO;
	};
	
	[self performSearchForProduct:gtin
									 name:nil
								language:language
								 orderBy:@"pl-lng_asc"
									 page:0
						recordsPerPage:0
							 completion:ownCompletion];
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
									 page:0
						recordsPerPage:0
							 completion:completion];
}

/**
 * Search for a product. If no search paramter are present the first 50 products will be presented.
 **/
- (void)performSearchForProduct:(NSString *)gtin
									name:(NSString *)name
							  language:(NSString *)language
								orderBy:(NSString *)orderBy
									page:(NSUInteger)page
					  recordsPerPage:(NSUInteger)rpp
							completion:(PLYCompletion)completion
{
	NSString *path;
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
 
	if (PLYIsValidGTIN(gtin))
	{
		path = [self _functionPathForFunction:[NSString stringWithFormat:@"/product/%@", gtin]];
	}
	else
	{
		path = [self _functionPathForFunction:@"products"];
		
		// this must be an invalid GTIN, nevertheless add it as search term
		if (gtin)
		{
			parameters[@"gtin"] = gtin;
		}
		
		if (name)
		{
			parameters[@"name"] = name;
		}
		
		if (orderBy)
		{
			parameters[@"order_by"] = orderBy;
		}
		
		if (page)
		{
			parameters[@"page"] = @(page);
		}
		
		if (rpp)
		{
			parameters[@"records_per_page"] = @(rpp);
		}
	}
	
	if (language)
	{
		parameters[@"language"] = language;
		
	}
	[self _performMethodCallWithPath:path
								 parameters:parameters
								 completion:completion];
}


- (void)searchForProductsMatchingQuery:(NSString *)query options:(NSDictionary *)options completion:(PLYCompletion)completion
{
	NSString *path = [self _functionPathForFunction:@"products"];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:options];
	parameters[@"query"] = query;
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if ([error code] == 404)
		{
			error = nil;
			result = @[];
		}
		
		if (result)
		{
			result = [self _arrayOfUpdatedCachedEntities:result];
		}
		
		if (completion)
		{
			completion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path parameters:parameters completion:wrappedCompletion];
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
	NSParameterAssert([user length]);
	NSParameterAssert([email length]);
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
	NSParameterAssert([user length]);
	NSParameterAssert([password length]);
	NSParameterAssert(completion);
	
	_performingLogin = YES;
    [self _clearSession];
    
	NSString *path = [self _functionPathForFunction:@"login"];
	
	NSString *authValue = [self basicAuthenticationForUser:user andPassword:password];
	
	PLYCompletion wrappedCompletion = [completion copy];
	
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (!error && [result isKindOfClass:PLYUser.class])
		{
			self.loggedInUser = [self _entityByUpdatingCachedEntity:result];
			[self _saveState];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
		
		_performingLogin = NO;
	};
	
	NSDictionary *parameters = @{@"remember_me": @"true"};
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:parameters basicAuth:authValue completion:ownCompletion];
}

- (NSString *) basicAuthenticationForUser:(NSString *)user andPassword:(NSString *)password{
	// Basic Authentication
	NSString *authStr = [NSString stringWithFormat:@"%@:%@", user, password];
	NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
	return [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
}

- (void)loginWithToken:(NSString *)token completion:(PLYCompletion)completion
{
	NSParameterAssert(token);
	NSParameterAssert(completion);

    [self _clearSession];

	_performingLogin = YES;
    
    // set token for restoring old session
    _authToken = token;
	
	NSString *path = [self _functionPathForFunction:@"login"];
	
	PLYCompletion wrappedCompletion = [completion copy];
	
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (!error && [result isKindOfClass:PLYUser.class])
		{
			self.loggedInUser = [self _entityByUpdatingCachedEntity:result];
			[self _saveState];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
		
		_performingLogin = NO;
	};
	
	NSDictionary *parameters = @{@"remember_me": @"true"};
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:parameters basicAuth:nil completion:ownCompletion];
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
		
		_authToken = nil;
	}
	
	NSString *path = [self _functionPathForFunction:@"logout"];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil completion:completion];
	
    [self _clearSession];
	[self _invalidateAuthToken];
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
										  completion:(PLYCompletion)completion
{
	NSParameterAssert(email);
	NSParameterAssert(completion);
	
	NSString *path = [self _functionPathForFunction:@"/user/lost_password"];
	
	NSDictionary *payload = [NSDictionary dictionaryWithObject:email forKey:@"email"];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:payload completion:completion];
}

/**
  Sets a new password for the user using a reset token
 **/
- (void)setUserPassword:(NSString *)password resetToken:(NSString *)resetToken completion:(PLYCompletion)completion
{
    NSParameterAssert(resetToken);
    NSParameterAssert(password);
    
    NSString *path = [self _functionPathForFunction:@"/user/change_password"];
    
    NSDictionary *parameters = @{@"reset_token": resetToken};
    NSDictionary *payload = @{@"new_password": password};
    
    
    [self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:parameters payload:payload completion:completion];
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
		
		if (result && !error)
		{
			// reset user avatar URL
			PLYUserAvatar *avatar = (PLYUserAvatar *)result;
			
			// update Avatar
			[user setValue:avatar forKey:@"avatar"];
			
			// persist for logged in user
			if (user == _loggedInUser)
			{
				[self _saveState];
			}
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
		if (result && !error)
		{
			// workaround, need to get new placeholder avatar
			[self loadDetailsForUser:user completion:NULL];
		}
		
		if (completion)
		{
			completion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil payload:nil completion:wrappedCompletion];
}

- (void)updateSetting:(NSString *)setting parameters:(NSDictionary *)parameters completion:(PLYCompletion)completion
{
    NSString *function = [NSString stringWithFormat:@"/user/setting/%@", setting];
    NSString *path = [self _functionPathForFunction:function];

    PLYCompletion wrappedCompletion = ^(PLYUser *result, NSError *error) {
        // reset logged in user avatar URL
        if (result)
        {
            [self _entityByUpdatingCachedEntity:result];
        }
        
        if (completion)
        {
            completion(result, error);
        }
    };
    
    [self _performMethodCallWithPath:path HTTPMethod:@"PUT" parameters:parameters payload:nil completion:wrappedCompletion];
}

#if TARGET_OS_IPHONE
- (void)registerPushToken:(NSData *)deviceToken completion:(__nullable PLYCompletion)completion
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSDictionary *infoDict = [mainBundle infoDictionary];
    
    NSUInteger capacity = deviceToken.length * 2;
    NSMutableString *deviceTokenHex = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = deviceToken.bytes;
    NSInteger i;
    
    for (i=0; i<deviceToken.length; ++i) {
        [deviceTokenHex appendFormat:@"%02lx", (unsigned long)buf[i]];
    }
    
    NSString *appID = mainBundle.bundleIdentifier;
    NSString *appName = infoDict[@"CFBundleName"];
    NSString *identifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    NSString *version = infoDict[@"CFBundleShortVersionString"];
    NSString *build = infoDict[@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    NSDictionary *payload = @{@"pl-push-app_identifier": appID,
                              @"pl-push-app_name": appName,
                              @"pl-push-app_version": appVersion,
                              @"pl-push-device_token": deviceTokenHex,
                              @"pl-push-device_type": @"ios",
                              @"pl-push-installation_id": identifier};
    
    NSString *path = [self _functionPathForFunction:@"/user/me/push/token"];

    [self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:payload completion:completion];
}
#endif


- (void)loadDetailsForUser:(PLYUser *)user completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	
	[self getUserByNickname:user.Id completion:^(id result, NSError *error) {
		// UI elements might be KVO details, so we do this on the main thread
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			
			if (result && !error)
			{
				PLYUser *cachedUser = [self _entityByUpdatingCachedEntity:result];
				
				if (cachedUser != user)
				{
					[user updateFromEntity:cachedUser];
				}
				
				if (completion)
				{
					completion(user, nil);
				}
				
				return;
			}
			
			if (completion)
			{
				completion(result, error);
			}
		});
	}];
}

- (void)achievementForKey:(NSString *)key completion:(PLYCompletion)completion
{
   	NSParameterAssert(key);
    
    NSString *function = [NSString stringWithFormat:@"/achievements/%@", key];
    NSString *path = [self _functionPathForFunction:function];
    
    [self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:nil payload:nil completion:completion];
}


- (void)loadAchievementsForUser:(PLYUser *)user completion:(PLYCompletion)completion
{
   	NSParameterAssert(user);
 
    NSString *function = [NSString stringWithFormat:@"/users/%@/achievements", user.Id];
    NSString *path = [self _functionPathForFunction:function];
    
//    PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
//        // reset logged in user avatar URL
//        if (result && !error)
//        {
//            // workaround, need to get new placeholder avatar
//            [self loadDetailsForUser:user completion:NULL];
//        }
//        
//        if (completion)
//        {
//            completion(result, error);
//        }
//    };
    
    [self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:nil payload:nil completion:completion];
}

#pragma mark - Managing Social Connections

- (NSURLRequest *)_URLRequestForSocialService:(NSString *)service function:(NSString *)function HTTPMethod:(NSString *)HTTPMethod
{
	NSParameterAssert(service);
	NSParameterAssert(function);
	NSParameterAssert(HTTPMethod);
	
	NSString *redirectStr = @"http://productlayer.com";
	
	NSString *functionPath = [NSString stringWithFormat:@"/%@/%@", function, service];
	NSString *path = [self _functionPathForFunction:functionPath];
	NSURL *methodURL = [self _methodURLForPath:path
											  parameters:@{@"callback": redirectStr}];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:methodURL];
	request.HTTPMethod = @"POST";
	
	// Add the API key to each request.
	NSAssert(_APIKey, @"Setting an API Key is required to perform requests. Use [[PLYServer sharedServer] setAPIKey:]");
	[request setValue:_APIKey forHTTPHeaderField:@"API-KEY"];
	
	return request;
}

- (NSURLRequest *)URLRequestForFacebookSignIn
{
	return [self _URLRequestForSocialService:@"facebook" function:@"signin" HTTPMethod:@"POST"];
}

- (NSURLRequest *)URLRequestForFacebookConnect
{
	NSAssert(_authToken, @"Cannot connect to Facebook with no user logged in");
	
	NSMutableURLRequest *mutableRequest = [[self _URLRequestForSocialService:@"facebook" function:@"connect" HTTPMethod:@"POST"] mutableCopy];
	[mutableRequest setValue:_authToken forHTTPHeaderField:@"X-ProductLayer-Auth-Token"];
	return [mutableRequest copy];
}

- (void)disconnectSocialConnectionForFacebook:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function = @"/connect/facebook";
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		if (result)
		{
			// update cache
			result = [self _entityByUpdatingCachedEntity:result];
		}
		
		if (completion)
		{
			completion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil payload:nil completion:wrappedCompletion];
}

- (NSURLRequest *)URLRequestForTwitterSignIn
{
	return [self _URLRequestForSocialService:@"twitter" function:@"signin" HTTPMethod:@"POST"];
}

- (NSURLRequest *)URLRequestForTwitterConnect
{
	NSAssert(_authToken, @"Cannot connect to Facebook with no user logged in");
	
	NSMutableURLRequest *mutableRequest = [[self _URLRequestForSocialService:@"twitter" function:@"connect" HTTPMethod:@"POST"] mutableCopy];
	[mutableRequest setValue:_authToken forHTTPHeaderField:@"X-ProductLayer-Auth-Token"];
	return [mutableRequest copy];
}

- (void)disconnectSocialConnectionForTwitter:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function = @"/connect/twitter";
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		if (result)
		{
			// update cache
			result = [self _entityByUpdatingCachedEntity:result];
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
- (void)createProduct:(PLYProduct *)product completion:(PLYCompletion)completion
{
	NSParameterAssert(product);
	NSParameterAssert(product.GTIN);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self createProduct:product completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *path = [self _functionPathForFunction:@"products"];
	NSDictionary *payload = [self _dictionaryRepresentationWithoutReadOnlyProperties:product];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if (result)
		{
			// update cache
			PLYProduct *updatedProduct = [self _entityByUpdatingCachedEntity:result];
			updatedProduct.createdBy = [self _entityByUpdatingCachedEntity:updatedProduct.createdBy];
			updatedProduct.updatedBy = [self _entityByUpdatingCachedEntity:updatedProduct.updatedBy];
			
			NSDictionary *userInfo = @{PLYServerDidUpdateEntityKey: updatedProduct};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidUpdateEntityNotification object:self userInfo:userInfo];
		}
		
		if (completion)
		{
			completion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:payload completion:wrappedCompletion];
}

/**
 * Update a specific product.
 * ATTENTION: Login required
 **/
- (void)updateProduct:(PLYProduct *)product completion:(PLYCompletion)completion
{
	NSParameterAssert(product);
	NSParameterAssert(product.GTIN);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self updateProduct:product completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *path = [self _functionPathForFunction:[NSString stringWithFormat:@"/product/%@",product.GTIN]];
	NSDictionary *payload = [self _dictionaryRepresentationWithoutReadOnlyProperties:product];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if (result)
		{
			// update cache
			PLYProduct *updatedProduct = [self _entityByUpdatingCachedEntity:result];
			updatedProduct.createdBy = [self _entityByUpdatingCachedEntity:updatedProduct.createdBy];
			updatedProduct.updatedBy = [self _entityByUpdatingCachedEntity:updatedProduct.updatedBy];
			
			NSDictionary *userInfo = @{PLYServerDidUpdateEntityKey: updatedProduct};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidUpdateEntityNotification object:self userInfo:userInfo];
		}
		
		if (completion)
		{
			completion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"PUT" parameters:nil payload:payload completion:wrappedCompletion];
}


#pragma mark - Working with Brands and Brand Owners

- (void)recommendedBrandOwnersForGTIN:(NSString *)GTIN completion:(PLYCompletion)completion
{
	NSParameterAssert(GTIN);
	NSParameterAssert(completion);
	
	NSString *path = [self _functionPathForFunction:[NSString stringWithFormat:@"/product/%@/recommended_brand_owners", GTIN]];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:nil completion:completion];
}


- (void)brandsWithCompletion:(PLYCompletion)completion
{
	NSString *path = [self _functionPathForFunction:[NSString stringWithFormat:@"/products/brands"]];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:nil completion:completion];
}

- (void)brandOwnersWithCompletion:(PLYCompletion)completion
{
	NSString *path = [self _functionPathForFunction:[NSString stringWithFormat:@"/products/brand_owners"]];
	
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
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self uploadImageData:data forGTIN:gtin completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *function = [NSString stringWithFormat:@"product/%@/images", gtin];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (!error)
		{
			[self _refreshProductsWithGTIN:gtin];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:data completion:ownCompletion];
}

- (void)deleteImage:(PLYImage *)image completion:(PLYCompletion)completion
{
	NSParameterAssert(image.Id);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/image/%@", image.fileId];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (!error)
		{
			NSDictionary *userInfo = @{PLYServerDidDeleteEntityKey: [result lastObject]};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidDeleteEntityNotification object:self userInfo:userInfo];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil payload:nil completion:ownCompletion];
}

- (void)rotateImage:(PLYImage *)image degrees:(NSUInteger)degrees completion:(PLYCompletion)completion
{
	NSParameterAssert(image.fileId);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/image/%@/rotate?degrees=%ld", image.fileId, (long)degrees];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (result)
		{
			result = [self _entityByUpdatingCachedEntity:result];
			
			NSDictionary *userInfo = @{PLYServerDidUpdateEntityKey: result};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidUpdateEntityNotification object:self userInfo:userInfo];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"PUT" parameters:nil payload:nil completion:ownCompletion];
}

- (NSURL *)URLForImage:(PLYImage *)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight crop:(BOOL)crop
{
	NSParameterAssert(image);
	
	if ([image.fileId isEqualToString:@"EXTERNAL"])
	{
		return image.imageURL;
	}
	
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
	
	// no image URL, construct it
	NSString *function = [NSString stringWithFormat:@"/image/%@.jpg", image.fileId];
	NSString *path = [self _functionPathForFunction:function];
	return [self _methodURLForPath:path parameters:parameters];
}

- (NSURL *)URLForProductImageWithGTIN:(NSString *)GTIN maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight crop:(BOOL)crop
{
	if (!PLYIsValidGTIN(GTIN))
	{
		return nil;
	}
	
	if ([GTIN length]<14)
	{
		// make sure it is 14 digits
		GTIN = [[@"00000000000000" stringByAppendingString:GTIN] substringWithRange:NSMakeRange([GTIN length], 14)];
	}
	
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
	
	// no image URL, construct it
	NSString *function = [NSString stringWithFormat:@"/product/%@/default_image", GTIN];
	NSString *path = [self _functionPathForFunction:function];
	return [self _methodURLForPath:path parameters:parameters];
}

// new array returned as result in completion handler
- (void)_uploadImagesWhereNecessary:(NSArray *)images forGTIN:(NSString *)GTIN completion:(PLYCompletion)completion
{
	// do it on background queue to not block the main thread or the NSURLSession thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		
		dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		__block NSError *imageUploadError;
		
		NSMutableArray *uploadedImages = [NSMutableArray new];
		
		for (PLYUploadImage *image in images)
		{
			if ([image isKindOfClass:[PLYUploadImage class]])
			{
				[self uploadImageData:(id)image.imageData forGTIN:GTIN completion:^(id result, NSError *error) {
					if (result)
					{
						// replace upload image with result
						[uploadedImages addObject:result];
					}
					else
					{
						imageUploadError = error;
					}
					
					dispatch_semaphore_signal(sema);
				}];
			}
			else
			{
				[uploadedImages addObject:image];
			}
			
			dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
			
			if (imageUploadError)
			{
				completion(nil, imageUploadError);
				return;
			}
		}
		
		id result = nil;
		
		if ([uploadedImages count])
		{
			result = [uploadedImages copy];
		}
		
		completion(result, nil);
	});
}

#pragma mark - Opines

- (void) performSearchForOpineWithGTIN:(NSString *)gtin
								  withLanguage:(NSString *)language
						fromUserWithNickname:(NSString *)nickname
							  showFriendsOnly:(BOOL)showFriendsOnly
										 orderBy:(NSString *)orderBy
											 page:(NSUInteger)page
								recordsPerPage:(NSUInteger)rpp
									 completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function = @"opines";
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (gtin)           [parameters setObject:gtin     forKey:@"gtin"];
	if (language)       [parameters setObject:language forKey:@"language"];
	if (nickname)       [parameters setObject:nickname forKey:@"nickname"];
	
	if (showFriendsOnly) [parameters setObject:@"true"   forKey:@"show_friends_only"];
	else                [parameters setObject:@"false"   forKey:@"show_friends_only"];
	
	if (orderBy)        [parameters setObject:orderBy  forKey:@"order_by"];
	if (page)           [parameters setObject:@(page)     forKey:@"page"];
	if (rpp)            [parameters setObject:@(rpp)      forKey:@"records_per_page"];
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

- (void)createOpine:(PLYOpine *)opine completion:(PLYCompletion)completion
{
	NSParameterAssert(opine);
	NSParameterAssert(opine.text);
	NSParameterAssert(opine.GTIN);
	NSParameterAssert(opine.language);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self createOpine:opine completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	// first we need to upload all PLYUploadImage objects
	[self _uploadImagesWhereNecessary:opine.images forGTIN:opine.GTIN completion:^(id result, NSError *error) {
		
		if (error)
		{
			completion(nil, error);
			return;
		}
		
		// at this point the images are all uploaded and turned into PLYImages
		opine.images = result;
		
		NSString *function = @"opines";
		NSString *path = [self _functionPathForFunction:function];
		NSDictionary *payload = [self _dictionaryRepresentationWithoutReadOnlyProperties:opine];
		
		PLYCompletion wrappedCompletion = [completion copy];
		PLYCompletion ownCompletion = ^(id result, NSError *error) {
			
			if (result)
			{
				result = [self _entityByUpdatingCachedEntity:result];
				
				NSDictionary *userInfo = @{PLYServerDidCreateEntityKey: result};
				[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidCreateEntityNotification object:self userInfo:userInfo];
				
				[self _refreshProductsWithGTIN:opine.GTIN];
			}
			
			if (wrappedCompletion)
			{
				wrappedCompletion(result, error);
			}
		};
		
		[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:payload completion:ownCompletion];
	}];
}

- (void)refreshOpine:(PLYOpine *)opine completion:(PLYCompletion)completion
{
	NSParameterAssert(opine.Id);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/opine/%@", opine.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (result)
		{
			result = [self _entityByUpdatingCachedEntity:result];
			
			NSDictionary *userInfo = @{PLYServerDidUpdateEntityKey: result};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidUpdateEntityNotification object:self userInfo:userInfo];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:nil payload:nil completion:ownCompletion];
}

- (void)deleteOpine:(PLYOpine *)opine completion:(PLYCompletion)completion
{
	NSParameterAssert(opine);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"opine/%@", opine.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if (!error || [error code]==404)
		{
			// broadcast info that this entity is no more
			
			NSDictionary *userInfo = @{PLYServerDidDeleteEntityKey: opine};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidDeleteEntityNotification object:self userInfo:userInfo];
		}
		
		completion(result, error);
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil payload:nil completion:wrappedCompletion];
}

#pragma mark - Reviews

/**
 * Search for reviews.
 **/
- (void) performSearchForReviewWithGTIN:(NSString *)gtin
									withLanguage:(NSString *)language
						 fromUserWithNickname:(NSString *)nickname
									  withRating:(float)rating
										  orderBy:(NSString *)orderBy
											  page:(NSUInteger)page
								 recordsPerPage:(NSUInteger)rpp
									  completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function = @"reviews";
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (gtin)       [parameters setObject:gtin      forKey:@"gtin"];
	if (language)   [parameters setObject:language  forKey:@"language"];
	if (nickname)   [parameters setObject:nickname  forKey:@"nickname"];
	if (rating)     [parameters setObject:@(rating) forKey:@"rating"];
	if (orderBy)    [parameters setObject:orderBy   forKey:@"order_by"];
	if (page)       [parameters setObject:@(page)   forKey:@"page"];
	if (rpp)        [parameters setObject:@(rpp)    forKey:@"records_per_page"];
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

#pragma mark - Lists

/**
 * Create a new product list for the authenticated user.
 * ATTENTION: Login required
 **/
- (void)createProductList:(PLYList *)list
					completion:(PLYCompletion)completion
{
	NSParameterAssert(list);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self createProductList:list completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *function = @"lists";
	NSString *path = [self _functionPathForFunction:function];
	NSDictionary *payload = [self _dictionaryRepresentationWithoutReadOnlyProperties:list];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if (!error || [error code]==404)
		{
			PLYList *list = result;
			
			// broadcast info that this list was modified
			NSDictionary *userInfo = @{PLYServerDidModifyListKey:list.Id};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidModifyListNotification object:self userInfo:userInfo];
		}
		
		completion(result, error);
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil payload:payload completion:wrappedCompletion];
}

/**
 * Request product lists for a specific user and type.
 * ATTENTION: Login required
 **/
- (void) performSearchForProductListFromUser:(PLYUser *)user
											andListType:(NSString *)listType
													 page:(NSUInteger)page
										recordsPerPage:(NSUInteger)rpp
											 completion:(PLYCompletion)completion{
	
	NSParameterAssert(completion);
	
	NSString *function = @"lists";
	NSString *path = [self _functionPathForFunction:function];
	
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (user)       [parameters setObject:user.Id  forKey:@"user_id"];
	if (listType)   [parameters setObject:listType forKey:@"language"];
	if (page)       [parameters setObject:@(page)     forKey:@"page"];
	if (rpp)        [parameters setObject:@(rpp)      forKey:@"records_per_page"];
	
	[self _performMethodCallWithPath:path parameters:parameters completion:completion];
}

- (void)listsOfUser:(PLYUser *)user options:(NSDictionary *)options completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/user/%@/lists", user.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	[self _performMethodCallWithPath:path parameters:nil completion:completion];
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
	NSDictionary *payload = [self _dictionaryRepresentationWithoutReadOnlyProperties:list];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if (!error || [error code]==404)
		{
			// broadcast info that this list was modified
			NSDictionary *userInfo = @{PLYServerDidModifyListKey:list.Id};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidModifyListNotification object:self userInfo:userInfo];
		}
		
		completion(result, error);
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"PUT" parameters:nil payload:payload completion:wrappedCompletion];
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

#pragma mark - List Items

/**
 * Replaces or add's the product to the list if it doesn't exist.
 * ATTENTION: Login required
 **/
- (void)addOrReplaceListItem:(PLYListItem *)listItem
					 toListWithId:(NSString *)listId
						completion:(PLYCompletion)completion{
	NSParameterAssert(listItem);
	NSParameterAssert(listItem.GTIN);
	NSParameterAssert(listId);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"list/%@/product/%@", listId,listItem.GTIN];
	NSString *path = [self _functionPathForFunction:function];
	NSDictionary *payload = [self _dictionaryRepresentationWithoutReadOnlyProperties:listItem];
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if (!error || [error code]==404)
		{
			// broadcast info that this list was modified
			NSDictionary *userInfo = @{PLYServerDidModifyListKey:listId};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidModifyListNotification object:self userInfo:userInfo];
		}
		
		completion(result, error);
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"PUT" parameters:nil payload:payload completion:wrappedCompletion];
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
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if (!error || [error code]==404)
		{
			// broadcast info that this list was modified
			
			NSDictionary *userInfo = @{PLYServerDidModifyListKey:listId};
			[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidModifyListNotification object:self userInfo:userInfo];
		}
		
		completion(result, error);
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"DELETE" parameters:nil completion:wrappedCompletion];
}

#pragma mark - List Sharing

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
- (void)searchForUsersMatchingQuery:(NSString *)query completion:(PLYCompletion)completion
{
	NSParameterAssert(query);
	NSParameterAssert(completion);
	
	NSString *function = @"users";
	NSString *path = [self _functionPathForFunction:function];
	NSDictionary *parameters = @{@"query": query};
	
	PLYCompletion wrappedCompletion = ^(id result, NSError *error) {
		
		if ([error code] == 404)
		{
			error = nil;
			result = @[];
		}
		
		if (result)
		{
			result = [self _arrayOfUpdatedCachedEntities:result];
		}
		
		if (completion)
		{
			completion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path parameters:parameters completion:wrappedCompletion];
}

/**
 * Follow a specific user.
 * ATTENTION: Login required
 **/
- (void)followUser:(PLYUser *)user completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self followUser:user completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *function = @"/user/follow";
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (!error && [result isKindOfClass:PLYUser.class])
		{
			// update user object
			[user setValue:@(YES) forKey:@"followed"];
			[user setValue:@(user.followerCount+1) forKey:@"followerCount"];
			
			// update cached object
			[self _entityByUpdatingCachedEntity:user];
			
			// update logged in user
			if ([result isEqual:_loggedInUser])
			{
				[_loggedInUser updateFromEntity:result];
			}
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	NSDictionary *params = @{@"nickname": user.nickname};
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:params completion:ownCompletion];
}

/**
 * Unfollow a specific user.
 * ATTENTION: Login required
 **/
- (void)unfollowUser:(PLYUser *)user completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self unfollowUser:user completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *function = @"/user/unfollow";
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (!error && [result isKindOfClass:PLYUser.class])
		{
			// update user object
			[user setValue:@(NO) forKey:@"followed"];
			[user setValue:@(user.followerCount-1) forKey:@"followerCount"];
			
			// update cached object
			[self _entityByUpdatingCachedEntity:user];
			
			// update logged in user
			if ([result isEqual:_loggedInUser])
			{
				[_loggedInUser updateFromEntity:result];
			}
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	NSDictionary *params = @{@"nickname": user.nickname};
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:params completion:ownCompletion];
}

- (void)followerForUser:(PLYUser *)user options:(NSDictionary *)options completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/user/%@/follower", user.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (result)
		{
			NSMutableArray *tmpArray = [NSMutableArray array];
			
			for (PLYUser *user in result)
			{
				PLYUser *cachedUser = [self _entityByUpdatingCachedEntity:user];
				[tmpArray addObject:cachedUser];
			}
			
			result = [tmpArray copy];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:options completion:ownCompletion];
}

- (void)followingForUser:(PLYUser *)user options:(NSDictionary *)options completion:(PLYCompletion)completion
{
	NSParameterAssert(user);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/user/%@/following", user.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (result)
		{
			NSMutableArray *tmpArray = [NSMutableArray array];
			
			for (PLYUser *user in result)
			{
				PLYUser *cachedUser = [self _entityByUpdatingCachedEntity:user];
				[tmpArray addObject:cachedUser];
			}
			
			result = [tmpArray copy];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:options completion:ownCompletion];
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

- (NSDictionary *)_timelineOptionsFromDictionary:(NSDictionary *)options
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:options];
	
	// default values
	params[PLYTimelineOptionIncludeOpines] = [options[PLYTimelineOptionIncludeOpines] boolValue]?@"true":@"false";
	params[PLYTimelineOptionIncludeImages] = [options[PLYTimelineOptionIncludeImages] boolValue]?@"true":@"false";
	params[PLYTimelineOptionIncludeReviews] = [options[PLYTimelineOptionIncludeReviews] boolValue]?@"true":@"false";
	params[PLYTimelineOptionIncludeProducts] = [options[PLYTimelineOptionIncludeProducts] boolValue]?@"true":@"false";
	params[PLYTimelineOptionIncludeFriends] = [options[PLYTimelineOptionIncludeFriends] boolValue]?@"true":@"false";
	
	return [params copy];
}

- (void)timelineForUser:(PLYUser *)user options:(NSDictionary *)options completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function;
 
	if (user)
	{
		function = [NSString stringWithFormat:@"/timeline/user/%@", user.Id];
	}
	else
	{
		function = @"/timeline/";
	}
	
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (result)
		{
			result = [self _arrayOfUpdatedCachedEntities:result];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	NSDictionary *params = [self _timelineOptionsFromDictionary:options];
	[self _performMethodCallWithPath:path parameters:params completion:ownCompletion];
}

- (void)timelineForProduct:(PLYProduct *)product options:(NSDictionary *)options completion:(PLYCompletion)completion
{
	NSParameterAssert(product);
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/timeline/product/%@", product.GTIN];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (result)
		{
			result = [self _arrayOfUpdatedCachedEntities:result];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	NSDictionary *params = [self _timelineOptionsFromDictionary:options];
	[self _performMethodCallWithPath:path parameters:params completion:ownCompletion];
}

#pragma mark - Votings

- (void)upVote:(PLYVotableEntity *)voteableEntity completion:(PLYCompletion)completion
{
	NSParameterAssert(voteableEntity);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self upVote:voteableEntity completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *entityType;
	if ([voteableEntity isKindOfClass:[PLYImage class]])
	{
		entityType = @"image";
	}
	else if ([voteableEntity isKindOfClass:[PLYProduct class]])
	{
		entityType = @"product";
	}
	else if ([voteableEntity isKindOfClass:[PLYOpine class]])
	{
		entityType = @"opine";
	}
	else if ([voteableEntity isKindOfClass:[PLYReview class]])
	{
		entityType = @"review";
	}
	
	NSAssert(entityType!=nil, @"Can't vote this entity.");
	
	NSString *function = [NSString stringWithFormat:@"%@/%@/up_vote", entityType, voteableEntity.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		if (result)
		{
			[voteableEntity updateFromEntity:result];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil completion:ownCompletion];
}

- (void)downVote:(PLYVotableEntity *)voteableEntity
		completion:(PLYCompletion)completion{
	
	NSParameterAssert(voteableEntity);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self downVote:voteableEntity completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *entityType;
	if ([voteableEntity isKindOfClass:[PLYImage class]])
	{
		entityType = @"image";
	}
	else if ([voteableEntity isKindOfClass:[PLYProduct class]])
	{
		entityType = @"product";
	}
	else if ([voteableEntity isKindOfClass:[PLYOpine class]])
	{
		entityType = @"opine";
	}
	else if ([voteableEntity isKindOfClass:[PLYReview class]])
	{
		entityType = @"review";
	}
	
	NSAssert(entityType!=nil, @"Can't vote this entity.");
	
	NSString *function = [NSString stringWithFormat:@"%@/%@/down_vote", entityType, voteableEntity.Id];
	NSString *path = [self _functionPathForFunction:function];
	
	PLYCompletion wrappedCompletion = [completion copy];
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		if (result)
		{
			[voteableEntity updateFromEntity:result];
		}
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:nil completion:ownCompletion];
}

#pragma mark - Problem Reports

- (void)createProblemReport:(PLYProblemReport *)report completion:(PLYCompletion)completion
{
	NSParameterAssert(report);
	NSParameterAssert(completion);
	
#if TARGET_OS_IPHONE
	if (!_loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				// retry now that we are logged in
				[self createProblemReport:report completion:completion];
			}
			else if (completion)
			{
				// report login failure
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOGIN_REQUIRED_ERROR", @"UI", @"Error message for activities that require login");
				NSError *error = [self _errorWithCode:404 message:msg];
				completion(nil, error);
			}
		}];
		
		return;
	}
#endif
	
	NSString *function;
	NSDictionary *parameters;
 
	if ([report.entity isKindOfClass:[PLYUser class]])
	{
		function = @"users/report_problem";
		parameters = @{@"user_id": report.entity.Id};
	}
	else if ([report.entity isKindOfClass:[PLYProduct class]])
	{
		function = @"products/report_problem";
		parameters = @{@"product_id": report.entity.Id};
	}
	else if ([report.entity isKindOfClass:[PLYUserAvatar class]])
	{
		function = @"users/report_problem";
		PLYUserAvatar *avatar = (PLYUserAvatar *)report.entity;
		PLYUser *user = avatar.createdBy;
		parameters = @{@"user_id": user.Id};
	}
	else if ([report.entity isKindOfClass:[PLYImage class]])
	{
		function = @"images/report_problem";
		parameters = @{@"image_id": report.entity.Id};
	}
	else if ([report.entity isKindOfClass:[PLYOpine class]])
	{
		function = @"opine/report_problem";
		parameters = @{@"opine_id": report.entity.Id};
	}
	else
	{
		NSAssert(NO, @"Can't report issue on such an entity");
	}
	
	NSString *path = [self _functionPathForFunction:function];
	NSDictionary *payload = [self _dictionaryRepresentationWithoutReadOnlyProperties:report];
	
	[self _performMethodCallWithPath:path HTTPMethod:@"POST" parameters:parameters payload:payload completion:completion];
}

#pragma mark - Working with Categories

- (void)_refreshCategories
{
    NSLog(@"Load Categories");
    
	[self categoriesWithLanguage:nil completion:^(id result, NSError *error) {
		if (error)
		{
			DTLogWarning(@"Unable to refresh category list: %@", [error localizedDescription]);
		}
		else
		{
			if (result == nil)
			{
				DTLogInfo(@"Categories not changed");
			}
			else if ([result isKindOfClass:[NSArray class]])
			{
				[_categoryManager mergeCategories:result error:NULL];
				
				NSLog(@"%ld first-level Categories loaded", (long)[result count]);
				
				// turn into flattened dictionary for more efficient lookup
				[[NSNotificationCenter defaultCenter] postNotificationName:PLYServerDidUpdateProductCategoriesNotification object:nil];
			}
		}
	}];
}

- (NSString *)localizedCategoryPathForKey:(NSString *)categoryKey
{
	if (!categoryKey)
	{
		return nil;
	}
	
	return [_categoryManager localizedCategoryPathForKey:categoryKey];
}

- (NSArray *)categoriesMatchingSearch:(nonnull NSString *)search
{
	return [_categoryManager categoriesMatchingSearch:search error:NULL];
}

- (void)categoryForKey:(NSString *)key language:(NSString *)language completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *function = [NSString stringWithFormat:@"/category/%@", key];
	NSString *path = [self _functionPathForFunction:function];
	NSDictionary *params = @{@"language": language?language:@"auto"};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:params payload:nil completion:completion];
}

- (void)categoriesWithLanguage:(NSString *)language completion:(PLYCompletion)completion
{
	NSParameterAssert(completion);
	
	NSString *usedLange = language?language:@"auto";
	
	NSString *function = @"/categories";
	NSString *path = [self _functionPathForFunction:function];
	NSDictionary *params = @{@"language": usedLange};
	
	PLYCompletion wrappedCompletion = [completion copy];
	
	PLYCompletion ownCompletion = ^(id result, NSError *error) {
		
		if (wrappedCompletion)
		{
			wrappedCompletion(result, error);
		}
	};
	
	[self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:params payload:nil completion:ownCompletion];
}

#pragma mark - Entities

- (PLYEntity *)retrieveEntityByIdentifier:(NSString *)identifier class:(Class)class completion:(PLYCompletion)completion
{
    NSParameterAssert(identifier);
    NSParameterAssert(class);
    
    NSString *plyClass = [class entityTypeIdentifier];
    
    NSString *function = nil;
    
    if ([plyClass isEqualToString:@"com.productlayer.Product"])
    {
        function = [@"/product/" stringByAppendingString:identifier];
    }
    else if ([plyClass isEqualToString:@"com.productlayer.Opine"])
    {
        function = [@"/opine/" stringByAppendingString:identifier];
    }
    else if ([plyClass isEqualToString:@"com.productlayer.Image"])
    {
        function = [NSString stringWithFormat:@"/image/%@/meta", identifier];
    }
    else if ([plyClass isEqualToString:@"com.productlayer.User"])
    {
        function = [@"/user/" stringByAppendingString:identifier];
    }
    
    NSAssert(function!=nil, @"No known path for query for '%@'", plyClass);
    
    NSString *path = [self _functionPathForFunction:function];
    
    PLYCompletion wrappedCompletion = [completion copy];
    
    PLYCompletion ownCompletion = ^(id result, NSError *error) {
        
        if (result)
        {
            result = [self _entityByUpdatingCachedEntity:result];
        }
        
        if (wrappedCompletion)
        {
            wrappedCompletion(result, error);
        }
    };
    
    [self _performMethodCallWithPath:path HTTPMethod:@"GET" parameters:nil payload:nil completion:ownCompletion];
    
    
    // return previously cached entity
    return [_entityCache objectForKey:identifier];
}


#pragma mark - Notifications

- (void)_didEnterForeground:(NSNotification *)notification
{
	if (self.loggedInUser)
	{
		// restore logged in user in cache
		[_entityCache setObject:self.loggedInUser forKey:self.loggedInUser.Id];
		
		DTLogInfo(@"Refreshing details for logged in user '%@'", self.loggedInUser.nickname);
		[self loadDetailsForUser:self.loggedInUser completion:NULL];
		
		[self _refreshCategories];
	}
}

- (void)_localeDidChange:(NSNotification *)notification
{
	// remove last modified to trigger new loading
	NSString *function = @"/categories";
	NSString *path = [self _functionPathForFunction:function];
	NSURL *methodURL = [self _methodURLForPath:path parameters:@{ @"language": @"auto" }];
	NSString *lang = [[NSLocale preferredLanguages] firstObject];
	NSString *key = [NSString stringWithFormat:@"%@-Last-Modified-%@", methodURL.absoluteString, lang];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	
	// language might have changed
	[self _refreshCategories];
}

#pragma mark - Properties

// lazy initializer for URL session
- (NSURLSession *)session
{
	if (!_session)
	{
		_session = [NSURLSession sessionWithConfiguration:_configuration];
	}
	
	return _session;
}

@end
