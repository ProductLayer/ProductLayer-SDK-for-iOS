//
//  DTManagedImage.m
//  PL
//
//  Created by Oliver Drobnik on 29.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DTManagedImage.h"

@implementation DTManagedImage

@dynamic uniqueIdentifier;
@dynamic variantIdentifier;
@dynamic fileData;
@dynamic lastAccessDate;
@dynamic fileSize;


- (void)setImageSize:(CGSize)imageSize
{
	[self setValue:@(imageSize.width) forKey:@"imageSizeWidth"];
	[self setValue:@(imageSize.height) forKey:@"imageSizeHeight"];
}

- (CGSize)imageSize
{
	CGFloat width = [[self valueForKey:@"imageSizeWidth"] floatValue];
	CGFloat height = [[self valueForKey:@"imageSizeHeight"] floatValue];
	
	return CGSizeMake(width, height);
}

@end
