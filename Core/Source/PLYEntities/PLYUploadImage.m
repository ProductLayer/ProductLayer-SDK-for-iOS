//
//  PLYUploadImage.m
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 11/01/15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYUploadImage.h"

@interface PLYUploadImage ()

// writable internally
@property (nonatomic, copy, readwrite) NSData *imageData;

@end

@implementation PLYUploadImage

+ (NSString *)entityTypeIdentifier
{
	return @"com.productlayer.Image.Upload";
}

- (instancetype)initWithImageData:(NSData *)data
{
	self = [super init];
	
	if (self)
	{
		_imageData = [data copy];
		self.Class = [[self class] entityTypeIdentifier];
	}
	
	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
	
	if (_imageData)
	{
		dict[@"imageData"] = _imageData;
	}
	
	// return immutable
	return [dict copy];
}

@end
