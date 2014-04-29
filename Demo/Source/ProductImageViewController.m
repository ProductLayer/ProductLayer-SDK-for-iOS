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
#import "PLYProductImage.h"
//#import "DTDownloadCache.h"

@interface ProductImageViewController () <UICollectionViewDataSource>
@end

@implementation ProductImageViewController
{
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
	PLYProductImage *imageData = _images[indexPath.item];
	
	ProductImageCollectionViewCell *cell = (ProductImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ProductImage" forIndexPath:indexPath];
	
	cell.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"collectionView: %f", collectionView.frame.size.width);
    NSLog(@"scale: %f", [UIScreen mainScreen].scale);
    
    int imageSize = floor((collectionView.frame.size.width-50)/2.0)*[UIScreen mainScreen].scale;
    
    NSURL *imageURL = [NSURL URLWithString:[imageData getUrlForWidth:imageSize andHeight:imageSize crop:@"true"]];
	
	[cell setThumbnailImageURL:imageURL];
	
    NSLog(@"%ld - %@", (long)indexPath.item, imageData.fileId);
    
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGSize size = CGSizeMake(floor((collectionView.frame.size.width-50)/4.0), floor((collectionView.frame.size.width-50)/4.0));
	return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    float topAndBottomSpacer = (collectionView.frame.size.height - floor((collectionView.frame.size.width-50)/4.0)*2 - 10)/2;
	return UIEdgeInsetsMake(topAndBottomSpacer, 10, topAndBottomSpacer, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 10;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(_gtin){
        [self loadImagesFromGtin:_gtin];
    }
}

- (void) loadLastImages{
    [[PLYServer sharedPLYServer] getLastUploadedImagesWithPage:0 andRPP:8 completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            
			_images = result;
			
			[self.collectionView reloadData];
		});
	}];
}

- (void) loadImagesFromGtin:(NSString *)gtin{
    self.gtin = gtin;
    
    if (!_gtin)
	{
		return;
	}
	
	[[PLYServer sharedPLYServer] getImagesForGTIN:_gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            
			_images = result;
			
			[self.collectionView reloadData];
		});
	}];
}


@end
