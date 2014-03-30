//
//  PLYAPIOperation.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductLayer.h"

#import "NSString+DTURLEncoding.h"
#import "UIApplication+DTNetworkActivity.h"
#import "DTLog.h"
#import "ProductLayerConfig.h"

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
	if ([_delegate respondsToSelector:@selector(operationWillExecute:)])
	{
		[_delegate operationWillExecute:self];
	}

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_operationURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
	
	// set method if set
	if (_HTTPMethod)
	{
		request.HTTPMethod = _HTTPMethod;
	}
    
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        if([[cookie name] isEqualToString:@"JSESSIONID"]){
            _accessToken = [cookie value];
            break;
        }
        NSLog(@"name: '%@'\n",   [cookie name]);
        NSLog(@"value: '%@'\n",  [cookie value]);
        NSLog(@"domain: '%@'\n", [cookie domain]);
        NSLog(@"path: '%@'\n",   [cookie path]);
    }
	
	// set cookie session token if set
	if (_accessToken)
	{
		NSString *value = [NSString stringWithFormat:@"JSESSIONID=%@", _accessToken];
		[request setValue:value forHTTPHeaderField:@"Cookie"];
	} else if (_BasicAuthentication){
        [request setValue:_BasicAuthentication forHTTPHeaderField:@"Authorization"];
    }
    
    // Add the api key to each request.
    [request setValue:PLY_API_KEY forHTTPHeaderField:@"API-KEY"];
	
	NSMutableString *debugMessage = [NSMutableString string];
	[debugMessage appendFormat:@"%@ %@\n", request.HTTPMethod, [_operationURL absoluteString]];

	// add body if set
	if (_payload)
	{
        if ([_payload isKindOfClass:[UIImage class]])
		{
			NSString *stringBoundary = @"0xKhTmLbOuNdArY---This_Is_ThE_BoUnDaRyy---pqo";
			
			// header value
			NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"", stringBoundary];
			
			// set header
			[request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
			
			//NSData *imageData = (NSData *)_payload;
            NSData *tmpPayload = UIImageJPEGRepresentation(_payload, 0.5);
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
		else if ([_payload isKindOfClass:[NSData class]])
		{
			NSString *stringBoundary = @"----=_Part_15_1001769400.1389805800711";
			
			// header value
			NSString *headerBoundary = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
			
			// set header
			[request addValue:headerBoundary forHTTPHeaderField:@"Content-Type"];
			
			//NSData *imageData = (NSData *)_payload;
			NSData *base64Data = [_payload base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength | NSDataBase64EncodingEndLineWithCarriageReturn];
			
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
		else if ([NSJSONSerialization isValidJSONObject:_payload])
		{
			[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
			
			NSData *payloadData = [NSJSONSerialization dataWithJSONObject:_payload options:0 error:NULL];
			[request setHTTPBody:payloadData];
			
			NSString *payloadString = [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding];
			[debugMessage appendString:payloadString];
		}
	}
	
	DTLogDebug(@"%@", debugMessage);
	
	NSHTTPURLResponse *response;
	NSError *error;
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
	NSString *resultString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	DTLogDebug(@"%@", resultString);
	
	NSInteger statusCode = 0;
	NSString *contentType = nil;
	BOOL ignoreContent = NO;
	
	// check response class
	
	if (!error)
	{
		if ([response isKindOfClass:[NSHTTPURLResponse class]])
		{
			contentType = [response allHeaderFields][@"Content-Type"];
			statusCode = [response statusCode];
			
			DTLogDebug(@"%@", [response allHeaderFields]);
		}
		else
		{
			NSString *errorMessage = [NSString stringWithFormat:@"Invalid response object of class '%@'", NSStringFromClass([response class])];
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorMessage};
			error = [NSError errorWithDomain:PLYErrorDomain code:0 userInfo:userInfo];
		}
	}
	
	// check status code range
	
	if (!error)
	{
		if (statusCode>0 && statusCode<300)
		{
			
		}
		else
		{
			NSString *errorMessage = [NSString stringWithFormat:@"Server returned error code %ld", (long)statusCode];
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey:  errorMessage};
			error = [NSError errorWithDomain:PLYErrorDomain code:statusCode userInfo:userInfo];
		}
	}
	
	// check response content type
	
	if (!error)
	{
		if ([responseData length])
		{
			if ([contentType hasPrefix:@"application/json"])
			{
				
			}
			else if ([contentType hasPrefix:@"text/plain"])
			{
				if (statusCode >= 200 && statusCode < 300)
				{
					NSString *plainText = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
					DTLogDebug(@"%@", plainText);
					
					ignoreContent = YES;
				}
				else
				{
					NSString *plainText = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
					NSString *errorMessage = [NSString stringWithFormat:@"Server returned plain text error '%@'", plainText];
					
					NSDictionary *userInfo = @{NSLocalizedDescriptionKey:  errorMessage};
					error = [NSError errorWithDomain:PLYErrorDomain code:0 userInfo:userInfo];
				}
			}
			else
			{
				NSString *errorMessage = [NSString stringWithFormat:@"Unknown response content type '%@'", contentType];
				
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey:  errorMessage};
				error = [NSError errorWithDomain:PLYErrorDomain code:0 userInfo:userInfo];
			}
		}
	}

	id result;

	if (_resultHandler)
	{
		if (!error && !ignoreContent)
		{
			result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
		}
		
		_resultHandler(result, error);
	}
	
	if ([_delegate respondsToSelector:@selector(operation:didExecuteWithError:)])
	{
		[_delegate operation:self didExecuteWithError:error];
	}
}

@end
