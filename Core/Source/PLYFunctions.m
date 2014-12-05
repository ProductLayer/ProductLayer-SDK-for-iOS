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
