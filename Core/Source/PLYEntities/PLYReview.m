//
//  PLYReview.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYReview.h"

#import "PLYUser.h"
#import "PLYPackaging.h"

@implementation PLYReview

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Review";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-created-by"])
	{
		
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.createdBy = [[PLYUser alloc] initWithDictionary:value];
		}
	}
	else if ([key isEqualToString:@"pl-rev-usr_upvotes"])
	{
		
		if ([value isKindOfClass:[NSArray class]])
		{
			
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value)
			{
				[myMembers addObject:valueMember];
			}
			
			self.upVoter = myMembers;
			
		}
	}
	else if ([key isEqualToString:@"pl-rev-usr_downvotes"])
	{
		
		if ([value isKindOfClass:[NSArray class]])
		{
			
			NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
			for (id valueMember in value)
			{
				[myMembers addObject:valueMember];
			}
			
			self.downVoter = myMembers;
		}
	}
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.updatedBy = [[PLYUser alloc] initWithDictionary:value];
		}
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-class"])
	{
		[self setValue:value forKey:@"Class"];
	}
	else if ([key isEqualToString:@"pl-id"])
	{
		[self setValue:value forKey:@"Id"];
	}  else if ([key isEqualToString:@"pl-version"])
	{
		[self setValue:value forKey:@"version"];
	}
	else if ([key isEqualToString:@"pl-created-by"])
	{
		[self setValue:value forKey:@"createdBy"];
	}
	else if ([key isEqualToString:@"pl-created-time"])
	{
		[self setValue:value forKey:@"createdTime"];
	}
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		[self setValue:value forKey:@"updatedBy"];
	}
	else if ([key isEqualToString:@"pl-upd-time"])
	{
		[self setValue:value forKey:@"updatedTime"];
	}
	else if ([key isEqualToString:@"pl-prod-gtin"])
	{
		[self setValue:value forKey:@"gtin"];
	}
	else if ([key isEqualToString:@"pl-rev-subj"])
	{
		[self setValue:value forKey:@"subject"];
	}
	else if ([key isEqualToString:@"pl-rev-body"])
	{
		[self setValue:value forKey:@"body"];
	}
	else if ([key isEqualToString:@"pl-rev-rating"])
	{
		[self setValue:value forKey:@"rating"];
	}
	else if ([key isEqualToString:@"pl-lng"])
	{
		[self setValue:value forKey:@"language"];
	}
	else if ([key isEqualToString:@"pl-rev-votes"])
	{
		[self setValue:value forKey:@"votingScore"];
	}
	else if ([key isEqualToString:@"pl-rev-usr_upvotes"])
	{
		[self setValue:value forKey:@"upVoter"];
	}
	else if ([key isEqualToString:@"pl-rev-usr_downvotes"])
	{
		[self setValue:value forKey:@"downVoter"];
	}
}

- (NSDictionary *) dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_gtin)
	{
		[dict setObject:_gtin forKey:@"pl-prod-gtin"];
	}
	
	if (_subject)
	{
		[dict setObject:_subject forKey:@"pl-rev-subj"];
	}
	
	if (_body)
	{
		[dict setObject:_body forKey:@"pl-rev-body"];
	}
	
	if (_rating)
	{
		[dict setObject:_rating forKey:@"pl-rev-rating"];
	}
	
	if (_language)
	{
		[dict setObject:_language forKey:@"pl-lng"];
	}
	
	if (_votingScore)
	{
		[dict setObject:_votingScore forKey:@"pl-rev-votes"];
	}
	
	if (_upVoter)
	{
		[dict setObject:_upVoter forKey:@"pl-rev-usr_upvotes"];
	}
	
	if (_downVoter)
	{
		[dict setObject:_downVoter forKey:@"pl-rev-usr_downvotes"];
	}
	
	// return immutable
	return [dict copy];
}

@end
