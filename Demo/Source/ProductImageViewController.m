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
//#import "DTDownloadCache.h"

@interface ProductImageViewController () <UICollectionViewDataSource>
@property (nonatomic, strong) PLYServer *server;
@end

@implementation ProductImageViewController
{
	NSArray *_images;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [_images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *imageDict = _images[indexPath.item];
	
	ProductImageCollectionViewCell *cell = (ProductImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ProductImage" forIndexPath:indexPath];
	
	cell.backgroundColor = [UIColor whiteColor];
	
	NSString *urlString = imageDict[@"url"];
	NSURL *imageURL = [NSURL URLWithString:urlString];
	
	[cell setImageURL:imageURL];
	
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize size = CGSizeMake(floor(collectionView.frame.size.width/2.0)-7, floor(collectionView.frame.size.width/2.0)-7);
	return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 5;
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
