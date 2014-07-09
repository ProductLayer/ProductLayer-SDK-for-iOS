//
//  PLYAuditor.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYAuditor.h"

@implementation PLYAuditor

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-usr-id"])
	{
		[self setValue:value forKey:@"userId"];
	}
	else if ([key isEqualToString:@"pl-app-id"])
	{
		[self setValue:value forKey:@"appId"];
	}
	else if ([key isEqualToString:@"pl-usr-nickname"])
	{
		[self setValue:value forKey:@"userNickname"];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (_userId)
	{
		[dict setObject:_userId forKey:@"pl-usr-id"];
	}
	
	if (_appId)
	{
		[dict setObject:_appId forKey:@"pl-app-id"];
	}
	
	if (_userNickname)
	{
		[dict setObject:_userNickname forKey:@"pl-usr-nickname"];
	}
	
	return dict;
}

@end
