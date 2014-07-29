//
//  PLYVotableEntity.m
//  PL
//
//  Created by Oliver Drobnik on 29/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYVotableEntity.h"
#import "PLYUser.h"

@implementation PLYVotableEntity

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-vote-usr_upvotes"])
	{
		if ([value isKindOfClass:[NSArray class]])
		{
			
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value)
			{
				[myMembers addObject:valueMember];
			}
			
			_upVoter = myMembers;
		}
	}
	else if ([key isEqualToString:@"pl-vote-usr_downvotes"])
	{
		if ([value isKindOfClass:[NSArray class]])
		{
			
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value)
			{
				[myMembers addObject:valueMember];
			}
			
			_downVoter = myMembers;
		}
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-vote-score"])
	{
		[self setValue:value forKey:@"votingScore"];
	}
	else if ([key isEqualToString:@"pl-vote-usr_upvotes"])
	{
		[self setValue:value forKey:@"upVoter"];
	}
	else if ([key isEqualToString:@"pl-vote-usr_downvotes"])
	{
		[self setValue:value forKey:@"downVoter"];
	}
	else
	{
		[super setValue:value forUndefinedKey:key];
	}
}

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_votingScore)
	{
		[dict setObject:_votingScore forKey:@"pl-vote-score"];
	}
	
	if ([_upVoter count])
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[_upVoter count]];
		
		for (PLYUser *user in _upVoter)
		{
			[tmpArray addObject:[user dictionaryRepresentation]];
		}
		
		[dict setObject:tmpArray forKey:@"pl-vote-usr_upvotes"];
	}
	
	if ([_downVoter count] > 0)
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[_downVoter count]];
		
		for (PLYUser *user in _downVoter)
		{
			[tmpArray addObject:[user dictionaryRepresentation]];
		}
		
		[dict setObject:tmpArray forKey:@"pl-vote-usr_downvotes"];
	}
	
	// return immutable
	return [dict copy];
}

@end
