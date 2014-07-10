//
//  PLYProductImage.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYImage.h"

#import "PLYAuditor.h"
#import "PLYServer.h"

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
			self.createdBy = [[PLYAuditor alloc] initWithDictionary:value];
		}
	}
	else if ([key isEqualToString:@"pl-upd-by"])
	{
		if ([value isKindOfClass:[NSDictionary class]])
		{
			self.updatedBy = [[PLYAuditor alloc] initWithDictionary:value];
		}
		
	}
	else if ([key isEqualToString:@"pl-img-usr_upvotes"])
	{
		self.upVoters = [NSMutableArray arrayWithCapacity:1];
		
		if ([value isKindOfClass:[NSArray class]])
		{
			for (NSDictionary *user in value)
			{
				[self.upVoters addObject:[[PLYAuditor alloc] initWithDictionary:user]];
			}
		}
	}
	else if ([key isEqualToString:@"pl-img-usr_downvotes"])
	{
		self.downVoters = [NSMutableArray arrayWithCapacity:1];
		
		if ([value isKindOfClass:[NSArray class]])
		{
			for (NSDictionary *user in value)
			{
				[self.downVoters addObject:[[PLYAuditor alloc] initWithDictionary:user]];
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
	if ([key isEqualToString:@"pl-id"])
	{
		[self setValue:value forKey:@"Id"];
	}
	else if ([key isEqualToString:@"pl-version"])
	{
		[self setValue:value forKey:@"version"];
	}
	else if ([key isEqualToString:@"pl-class"])
	{
		[self setValue:value forKey:@"Class"];
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
		[self setValue:value forKey:@"udpatedBy"];
	}
	else if ([key isEqualToString:@"pl-upd-time"])
	{
		[self setValue:value forKey:@"updatedTime"];
	}
	else if ([key isEqualToString:@"pl-img-file_id"])
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
	else if ([key isEqualToString:@"pl-img-vote_score"])
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
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
	
	if (_Class)
	{
		[dict setObject:_Class forKey:@"pl-class"];
	}
	
	if (_Id)
	{
		[dict setObject:_Id forKey:@"pl-id"];
	}
	
	if (_version)
	{
		[dict setObject:_version forKey:@"pl-version"];
	}
	
	if (_createdBy)
	{
		[dict setObject:[_createdBy dictionaryRepresentation] forKey:@"pl-created-by"];
	}
	
	if (_createdTime)
	{
		[dict setObject:_createdTime forKey:@"pl-created-time"];
	}
	
	if (_updatedBy)
	{
		[dict setObject:[_updatedBy dictionaryRepresentation] forKey:@"pl-upd-by"];
	}
	
	if (_updatedTime)
	{
		[dict setObject:_updatedTime forKey:@"pl-upd-time"];
	}
	
	if (_fileId)
	{
		[dict setObject:_fileId forKey:@"pl-img-file_id"];
	}
	
	if (_height)
	{
		[dict setObject:_height forKey:@"pl-img-h-px"];
	}
	
	if (_name)
	{
		[dict setObject:_name forKey:@"pl-img-name"];
	}
	
	if (_url)
	{
		[dict setObject:_url forKey:@"pl-img-url"];
	}
	
	if (_votingScore)
	{
		[dict setObject:_votingScore forKey:@"pl-img-vote_score"];
	}
	
	if (_width)
	{
		[dict setObject:_width forKey:@"pl-img-w-px"];
	}
	
	if (_gtin)
	{
		[dict setObject:_gtin forKey:@"pl-prod-gtin"];
	}
	
	if (_upVoters && [_upVoters count] > 0)
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[_upVoters count]];
		
		for (PLYAuditor *user in _upVoters)
		{
			[tmpArray addObject:[user dictionaryRepresentation]];
		}
		
		[dict setObject:tmpArray forKey:@"pl-img-usr_upvotes"];
	}
	
	if (_downVoters && [_downVoters count] > 0)
	{
		NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[_downVoters count]];
		
		for (PLYAuditor *user in _downVoters)
		{
			[tmpArray addObject:[user dictionaryRepresentation]];
		}
		
		[dict setObject:tmpArray forKey:@"pl-img-usr_downvotes"];
	}
	
	return dict;
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
	
	if (_url)
	{
		NSString *path = [PLYServer _addQueryParameterToUrl:_url parameters:parameters];
		return path;
	}
	
	return nil;
}

@end
