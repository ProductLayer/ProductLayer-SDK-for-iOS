//
//  PLYErrorMessage.m
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYErrorMessage.h"

@implementation PLYErrorMessage

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"message"])
	{
		self.message = value;
	}
	else if ([key isEqualToString:@"code"])
	{
		self.code = value;
	}
	else if ([key isEqualToString:@"throwable"])
	{
		self.throwable = value;
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

@end
