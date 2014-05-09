//
//  DTScannedCode.m
//  TagScan
//
//  Created by Oliver Drobnik on 8/1/13.
//  Copyright (c) 2013 Oliver Drobnik. All rights reserved.
//

#import "DTScannedCode.h"
#import <AVFoundation/AVFoundation.h>

@implementation DTScannedCode
{
	NSString *_type;
	NSString *_content;
}

- (id)initWithType:(NSString *)type content:(NSString *)content
{
	self = [super init];
	
	if (self)
	{
		_type = [type copy];
		_content = [content copy];
	}
	
	return self;
}

+ (instancetype)scannedCodeFromMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObject
{
	return [[DTScannedCode alloc] initWithType:metadataObject.type content:[metadataObject stringValue]];
}

- (NSUInteger)hash
{
	return [_content hash]+31*[_type hash];
}

- (BOOL)isEqual:(DTScannedCode *)otherCode
{
	if (![_type isEqualToString:otherCode.type])
	{
		return NO;
	}
	
	return [_content isEqualToString:otherCode.content];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %@:%@>", NSStringFromClass([self class]), _type, _content];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_type forKey:@"Type"];
	[coder encodeObject:_content forKey:@"Content"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	NSString *type = [coder decodeObjectForKey:@"Type"];
	NSString *content = [coder decodeObjectForKey:@"Content"];
	
	return [self initWithType:type content:content];
}



@end