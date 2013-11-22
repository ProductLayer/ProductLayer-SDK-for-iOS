//
//  PLYAPIOperation.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYAPIOperation.h"
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

@end
