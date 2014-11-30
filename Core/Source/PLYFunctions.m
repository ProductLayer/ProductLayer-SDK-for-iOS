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