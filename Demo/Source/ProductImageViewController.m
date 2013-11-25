//
//  ProductImageViewController.m
//  PL
//
//  Created by Oliver Drobnik on 25.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductImageViewController.h"

#import "PLYServer.h"
#import "DTBlockFunctions.h"
#import "ProductImageCollectionViewCell.h"
#import "DTDownloadCache.h"

@interface ProductImageViewController () <UICollectionViewDataSource>
@property (nonatomic, strong) PLYServer *server;
@end

@implementation ProductImageViewController
{
	NSArray *_images;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [_images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *imageDict = _images[indexPath.item];
	
	ProductImageCollectionViewCell *cell = (ProductImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ProductImage" forIndexPath:indexPath];
	
	
	
	
	return cell;
}



- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (!_gtin)
	{
		return;
	}
	
	[self.server getImagesForGTIN:_gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{

			_images = result;
			
			[self.collectionView reloadData];
		});
	}];
}


@end
