//
//  PLYFunctions.m
//  PL
//
//  Created by Oliver Drobnik on 30/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYFunctions.h"
#import "PLYProduct.h"

PLYProduct *PLYProductBestMatchingUserPreferredLanguages(NSArray *products)
{
	for (NSString *lang in [NSLocale preferredLanguages])
	{
		for (PLYProduct *product in products)
		{
			if ([product.language isEqualToString:lang])
			{
				return product;
			}
		}
	}
	
	// preferred language does not exist
	NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"updatedTime" ascending:NO];
	NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:NO];
	
	NSArray *sorted = [products sortedArrayUsingDescriptors:@[sort1, sort2]];
	
	return [sorted firstObject];
}


#pragma mark - Localization and Resources

NSBundle *PLYResourceBundle()
{
	// bundle reference only retrieved once
	static NSBundle *_resourceBundle = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// get the same bundle where one of the core entities classes are located in
		NSBundle *bundle = [NSBundle bundleForClass:[PLYImage class]];
		NSString *extension = [[bundle bundlePath] pathExtension];
		
		// inside a framework, the framework IS the resource bundle
		_resourceBundle = bundle;
		
		// in apps and unit tests we need to get the bundle
		if ([extension isEqualToString:@"app"] ||
			 [extension isEqualToString:@"xctest"])
		{
			NSString *resourceBundlePath = [bundle pathForResource:@"ProductLayerSDK" ofType:@"bundle"];
			_resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
		}
	});
	
	return _resourceBundle;
}

DTColor *PLYBrandColor()
{
	return [DTColor colorWithRed:110.0/256.0 green:190.0/256.0 blue:68.0/256.0 alpha:1];
}

BOOL PLYGTINIsValidGlobally(NSString *GTIN)
{
	NSUInteger length = [GTIN length];
	
	if (!(length == 8 ||
			length == 12 ||
			length == 13))
	{
		[NSException raise:@"PLYGTINException" format:@"Incorrect GTIN Length"];
	}
	
	if (length == 12)
	{
		// add invisible 0 to GTIN-12
		GTIN = [@"0" stringByAppendingString:GTIN];
		length++;
	}
	
	// handle GTIN-13
	
	if (length == 13)
	{
		if ([GTIN hasPrefix:@"02"])
		{
			// GS1 Variable Measure Trade Item identification for restricted distribution
			return NO;
		}

		if ([GTIN hasPrefix:@"04"])
		{
			// GS1 restricted circulation number within a company
			return NO;
		}

		if ([GTIN hasPrefix:@"05"])
		{
			// GS1 US coupon identification
			return NO;
		}
		
		NSUInteger prefix2 = [[GTIN substringToIndex:2] integerValue];
		
		if (prefix2 >= 20 && prefix2 <= 29)
		{
			// GS1 restricted circulation number within a geographic region
			return NO;
		}
		
		if ([GTIN hasPrefix:@"980"])
		{
			// GS1 identification of Refund Receipts
			return NO;
		}
		
		NSUInteger prefix3 = [[GTIN substringToIndex:3] integerValue];
		
		if (prefix3 >= 981 && prefix3 <= 984)
		{
			// GS1 coupon identification for common currency areas
			return NO;
		}

		if (prefix3 >= 985 && prefix3 <= 989)
		{
			// Reserved for further GS1 coupon identification
			return NO;
		}
		
		if ([GTIN hasPrefix:@"99"])
		{
			// GS1 coupon identification
			return NO;
		}
		
		return YES;
	}
	
	// handle GTIN-8
	
	if ([GTIN hasPrefix:@"0"])
	{
		// Velocity Codes
		return NO;
	}
	
	if ([GTIN hasPrefix:@"2"])
	{
		// GS1 restricted circulation number within a company
		return NO;
	}
	
	NSUInteger prefix2 = [[GTIN substringToIndex:2] integerValue];
	
	if (prefix2 >= 97 && prefix2 <= 99)
	{
		// Reserve
		return NO;
	}
	
	NSUInteger prefix3 = [[GTIN substringToIndex:3] integerValue];
	
	if ((prefix3 >= 140 && prefix3 <= 199))
	{
		// Reserve
		return NO;
	}
	
	// 100-139, 300-969 fall through
	return YES;
}


/**
 Creates MongoDB/Java timestamp from NSDate
 */
NSDate *PLYJavaTimestampToNSDate(double timestamp)
{
	NSTimeInterval seconds = timestamp/1000.0;
	return [NSDate dateWithTimeIntervalSince1970:seconds];
}

double PLYJavaTimestampFromNSDate(NSDate *date)
{
	NSTimeInterval seconds = [date timeIntervalSince1970];
	return seconds * 1000.0;
}
