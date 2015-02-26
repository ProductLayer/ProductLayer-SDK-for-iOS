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
				PLYUser *user = [[PLYUser alloc] initWithDictionary:valueMember];
				[myMembers addObject:user];
			}
			
			self.upVoter = myMembers;
		}
	}
	else if ([key isEqualToString:@"pl-vote-usr_downvotes"])
	{
		if ([value isKindOfClass:[NSArray class]])
		{
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value)
			{
				PLYUser *user = [[PLYUser alloc] initWithDictionary:valueMember];
				[myMembers addObject:user];
			}
			
			self.downVoter = myMembers;
		}
	}
	else if ([key isEqualToString:@"pl-vote-score"])
	{
		[self setValue:value forKey:@"votingScore"];
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_votingScore)
	{
		dict[@"pl-vote-score"] = @(_votingScore);
	}
	
	if ([_upVoter count])
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[_upVoter count]];
		
		for (PLYUser *user in _upVoter)
		{
			[tmpArray addObject:[user dictionaryRepresentation]];
		}
		
		dict[@"pl-vote-usr_upvotes"] = tmpArray;
	}
	
	if ([_downVoter count] > 0)
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[_downVoter count]];
		
		for (PLYUser *user in _downVoter)
		{
			[tmpArray addObject:[user dictionaryRepresentation]];
		}
		
		dict[@"pl-vote-usr_downvotes"] = tmpArray;
	}
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYVotableEntity *)entity
{
	[super updateFromEntity:entity];
	
	self.votingScore = entity.votingScore;
	self.upVoter = entity.upVoter;
	self.downVoter = entity.downVoter;
}

- (BOOL)canBeVoted
{
	if (self.Id)
	{
		return YES;
	}
	
	return NO;
}

@end
