//
//  PLYAPIOperation.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductLayer.h"

#import "NSString+DTURLEncoding.h"

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
			functionPath = [functionPath stringByAppendingString:tmpQuery];
		}
		
		_operationURL = [NSURL URLWithString:functionPath relativeToURL:endpointURL];
		
		NSAssert(_operationURL, @"Something went wrong with creating a %@", NSStringFromClass([self class]));
	}
	
	return self;
}

- (void)main
{
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_operationURL];
	
	NSHTTPURLResponse *response;
	NSError *error;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (!error)
	{
		if ([response isKindOfClass:[NSHTTPURLResponse class]])
		{
			NSString *contentType = [response allHeaderFields][@"Content-Type"];
			
			if (![contentType isEqualToString:@"application/json"])
			{
				// unknown error
				NSString *errorMessage;
				
				if ([contentType hasPrefix:@"text"])
				{
					errorMessage = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
				}
				else
				{
					errorMessage = [NSString stringWithFormat:@"Unknown response content type '%@'", contentType];
				}
				
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey:  errorMessage};
				error = [NSError errorWithDomain:PLYErrorDomain code:0 userInfo:userInfo];
			}
		}
		else
		{
			NSString *errorMessage = [NSString stringWithFormat:@"Invalid response object of class '%@'", NSStringFromClass([response class])];
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorMessage};
			error = [NSError errorWithDomain:PLYErrorDomain code:0 userInfo:userInfo];
		}
	}
	
	if (_resultHandler)
	{
		id result;
		
		if (!error)
		{
			result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
		}
		
		_resultHandler(result, error);
	}
}

@end
