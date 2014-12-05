//
//  PLYCompatibility.h
//  PL
//
//  Created by Oliver Drobnik on 30/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//


#pragma mark - iOS

#if TARGET_OS_IPHONE

@compatibility_alias DTColor	UIColor;
@compatibility_alias DTImage	UIImage;

// method for creating data from an NSImage
static inline NSData *DTImageJPEGRepresentation(DTImage *image, CGFloat compressionQuality)
{
	return UIImageJPEGRepresentation(image, compressionQuality);
}

#endif


#pragma mark - Mac


#if !TARGET_OS_IPHONE

@compatibility_alias DTColor	NSColor;
@compatibility_alias DTImage	NSImage;


// method for creating data from an NSImage
static inline NSData *DTImageJPEGRepresentation(DTImage *image, CGFloat compressionQuality)
{
	[image lockFocus];
	NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,
																															 0,
																															 image.size.width,
																															 image.size.height)];
	[image unlockFocus];
	
	NSDictionary *properties = @{NSImageCompressionFactor: @(0.8)};
	return [bitmapRep representationUsingType:NSJPEGFileType properties:properties];
}


#endif

// this enables generic ceil, floor, abs, round functions that work for 64 and 32 bit
#include <tgmath.h>
