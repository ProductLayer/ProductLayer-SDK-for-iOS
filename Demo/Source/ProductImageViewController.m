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
	NSDictionary *imageDict = _images[indexPath.item];
	
	ProductImageCollectionViewCell *cell = (ProductImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ProductImage" forIndexPath:indexPath];
	
	cell.backgroundColor = [UIColor whiteColor];
	
    NSString *image_id = imageDict[@"pl-img-file_id"];
    NSString *urlString = imageDict[@"pl-img-url"];
    
    NSURL *imageURL;
    if(urlString)
        imageURL = [NSURL URLWithString:[urlString stringByAppendingFormat:@"?max_width=%d",(int)(floor((collectionView.frame.size.width-50)/4.0)*[UIScreen mainScreen].scale)]];
    else
        imageURL = [_server imageURLForProductGTIN:_gtin imageIdentifier:image_id maxWidth:floor((collectionView.frame.size.width-50)/4.0)*[UIScreen mainScreen].scale];
	
	[cell setThumbnailImageURL:imageURL];
	
    NSLog(@"%ld - %@", (long)indexPath.item, image_id);
    
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
    [self.server getLastUploadedImagesWithPage:0 andRPP:10 completion:^(id result, NSError *error) {
		
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
	
	[self.server getImagesForGTIN:_gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            
			_images = result;
			
			[self.collectionView reloadData];
		});
	}];
}


@end
