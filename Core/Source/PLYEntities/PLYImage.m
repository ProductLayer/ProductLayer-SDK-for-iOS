//
//  PLYProductImage.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYImage.h"
#import "PLYUser.h"

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
    else if ([key isEqualToString:@"pl-img-dominant_color_hex"])
    {
        self.dominantColor = value;
    }
    else if ([key isEqualToString:@"pl-img-dominant_color"])
    {
        // ignore
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
    
    if (self.dominantColor)
    {
        dict[@"pl-img-dominant_color_hex"] = self.dominantColor;
    }
	
	// return immutable
	return [dict copy];
}

- (void)updateFromEntity:(PLYImage *)entity
{
	[super updateFromEntity:entity];
	
	self.fileId = entity.fileId;
	self.height = entity.height;
	self.width = entity.width;
	self.name = entity.name;
	self.imageURL = entity.imageURL;
	self.GTIN = entity.GTIN;
    self.dominantColor = entity.dominantColor;
}

- (BOOL)canBeVoted
{
	if (self.fileId)
	{
		return YES;
	}
	
	return NO;
}

@end
