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
		NSBundle *bundle = [NSBundle bundleForClass:[PLYImage class]];
		NSString *extension = [[bundle bundlePath] pathExtension];
		
		if ([extension isEqualToString:@"app"])
		{
			// inside .app we need to get the resource bundle
			NSString *resourceBundlePath = [bundle pathForResource:@"ProductLayer" ofType:@"bundle"];
			_resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
		}
		else 	if ([extension isEqualToString:@"framework"])
		{
			// inside .framework the framework is the resource bundle
			_resourceBundle = bundle;
		}
	});
	
	return _resourceBundle;
}

DTColor *PLYBrandColor()
{
	return [DTColor colorWithRed:110.0/256.0 green:190.0/256.0 blue:68.0/256.0 alpha:1];
}
