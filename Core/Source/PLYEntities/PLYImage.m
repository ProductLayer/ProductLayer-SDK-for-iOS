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
	if ([key isEqualToString:@"pl-img-file_id"])
	{
		self.fileId = value;
	}
	else if ([key isEqualToString:@"pl-img-h-px"])
	{
		[self setValue:value forKey:@"height"];
	}
	else if ([key isEqualToString:@"pl-img-name"])
	{
		self.name = value;
	}
	else if ([key isEqualToString:@"pl-img-url"])
	{
		self.imageURL = [NSURL URLWithString:value];
	}
	else if ([key isEqualToString:@"pl-img-w-px"])
	{
		[self setValue:value forKey:@"width"];
	}
	else if ([key isEqualToString:@"pl-prod-gtin"])
	{
		self.GTIN = value;
	}
	else
	{
		[super setValue:value forKey:key];
	}
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_fileId)
	{
		dict[@"pl-img-file_id"] = _fileId;
	}
	
	if (_height)
	{
		dict[@"pl-img-h-px"] = @(_height);
	}
	
	if (_name)
	{
		dict[@"pl-img-name"] = _name;
	}
	
	if (_imageURL)
	{
		dict[@"pl-img-url"] = [_imageURL absoluteString];
	}
	
	if (_width)
	{
		dict[@"pl-img-w-px"] = @(_width);
	}
	
	if (_GTIN)
	{
		dict[@"pl-prod-gtin"] = _GTIN;
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
	
	if (_imageURL)
	{
		NSString *urlString = [_imageURL absoluteString];
		NSString *path = [PLYServer _addQueryParameterToUrl:urlString parameters:parameters];
		return path;
	}
	
	return nil;
}

@end
