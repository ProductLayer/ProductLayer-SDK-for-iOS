//
//  PLYBrandOwnerViewController.m
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "ProductLayer.h"

@interface PLYBrandOwnerViewController ()

@end

@implementation PLYBrandOwnerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.title = PLYLocalizedStringFromTable(@"PLY_BRANDS_TITLE", @"UI", @"Title of the view controller showing brands");
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!_GTIN)
	{
		return;
	}
	
	[self.productLayerServer getRecommendedBrandOwnersForGTIN:_GTIN completion:^(id result, NSError *error) {
		NSLog(@"%@", [[result firstObject] dictionaryRepresentation]);
	}];

}


@end
