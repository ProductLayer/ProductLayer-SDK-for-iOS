//
//  PLYProductImage.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYServer.h"

#import "PLYImage.h"
#import "PLYUser.h"

@interface PLYServer (private)
+(NSString *)_addQueryParameterToUrl:(NSString *)url parameters:(NSDictionary *)parameters;
@end

@implementation PLYImage

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Image";
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
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.updatedBy = [[PLYUser alloc] initWithDictionary:value];
		}
		
	}
	else if ([key isEqualToString:@"pl-vote-usr_upvotes"])
	{
		self.upVoters = [NSMutableArray arrayWithCapacity:1];
		
		if ([value isKindOfClass:[NSArray class]])
		{
			for (NSDictionary *user in value)
			{
				[self.upVoters addObject:[[PLYUser alloc] initWithDictionary:user]];
			}
		}
	}
	else if ([key isEqualToString:@"pl-vote-usr_downvotes"])
	{
		self.downVoters = [NSMutableArray arrayWithCapacity:1];
		
		if ([value isKindOfClass:[NSArray class]])
		{
			for (NSDictionary *user in value)
			{
				[self.downVoters addObject:[[PLYUser alloc] initWithDictionary:user]];
			}
		}
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	if ([key isEqualToString:@"pl-img-file_id"])
	{
		[self setValue:value forKey:@"fileId"];
	}
	else if ([key isEqualToString:@"pl-img-h-px"])
	{
		[self setValue:value forKey:@"height"];
	}
	else if ([key isEqualToString:@"pl-img-name"])
	{
		[self setValue:value forKey:@"name"];
	}
	else if ([key isEqualToString:@"pl-img-url"])
	{
		[self setValue:value forKey:@"url"];
	}
	else if ([key isEqualToString:@"pl-vote-score"])
	{
		[self setValue:value forKey:@"votingScore"];
	}
	else if ([key isEqualToString:@"pl-img-w-px"])
	{
		[self setValue:value forKey:@"width"];
	}
	else if ([key isEqualToString:@"pl-prod-gtin"])
	{
		[self setValue:value forKey:@"gtin"];
	}
	else
	{
		[super setValue:value forUndefinedKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (self.fileId)
	{
		[dict setObject:self.fileId forKey:@"pl-img-file_id"];
	}
	
	if (self.height)
	{
		[dict setObject:self.height forKey:@"pl-img-h-px"];
	}
	
	if (self.name)
	{
		[dict setObject:self.name forKey:@"pl-img-name"];
	}
	
	if (self.url)
	{
		[dict setObject:self.url forKey:@"pl-img-url"];
	}
	
	if (self.votingScore)
	{
		[dict setObject:self.votingScore forKey:@"pl-vote-score"];
	}
	
	if (self.width)
	{
		[dict setObject:self.width forKey:@"pl-img-w-px"];
	}
	
	if (self.gtin)
	{
		[dict setObject:self.gtin forKey:@"pl-prod-gtin"];
	}
	
	if (self.upVoters && [self.upVoters count] > 0)
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self.upVoters count]];
		
		for (PLYUser *user in self.upVoters)
		{
			[tmpArray addObject:[user dictionaryRepresentation]];
		}
		
		[dict setObject:tmpArray forKey:@"pl-vote-usr_upvotes"];
	}
	
	if (self.downVoters && [self.downVoters count] > 0)
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self.downVoters count]];
		
		for (PLYUser *user in self.downVoters)
		{
			[tmpArray addObject:[user dictionaryRepresentation]];
		}
		
		[dict setObject:tmpArray forKey:@"pl-vote-usr_downvotes"];
	}
	
	// return immutable
	return [dict copy];
}

- (NSString *)getUrlForWidth:(CGFloat)maxWidth andHeight:(CGFloat)maxHeight crop:(BOOL)crop
{
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
	
	if (self.url)
	{
		NSString *path = [PLYServer _addQueryParameterToUrl:self.url parameters:parameters];
		return path;
	}
	
	return nil;
}

@end
