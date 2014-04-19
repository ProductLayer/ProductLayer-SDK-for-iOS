//
//  ProductImageCollectionViewCell.m
//  PL
//
//  Created by Oliver Drobnik on 25.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductImageCollectionViewCell.h"
#import "DTDownloadCache.h"
#import "DTBlockFunctions.h"
#import "DTLog.h"
#import "UIImage+DTFoundation.h"
#import "DTCoreGraphicsUtils.h"
#import "NSURL+DTComparing.h"
#import "NSString+DTPaths.h"

#import "DTImageCache.h"

@implementation ProductImageCollectionViewCell
{
	NSURL *_imageURL;
}

- (void)_setImage:(UIImage *)image
{
    // Ask Oliver why this was necessary. Caused re-ordering bug from UICollectionView.
	/*
     if (self.imageView.image)
	{
		return;
	}*/
	
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		self.imageView.image = image;
	});
}


- (void)_prepareAndStoreThumbnailForImage:(UIImage *)image
{
	DTImageCache *cache = [DTImageCache sharedCache];
	
	// store the original
	NSString *imageIdentifier = [_imageURL lastPathComponent];
	
	CGSize optimalSize = DTCGSizeThatFillsKeepingAspectRatio(image.size, CGSizeMake(153, 153));
	UIImage *scaledImage = [image imageScaledToSize:optimalSize];
	
	[cache addImage:scaledImage forUniqueIdentifier:imageIdentifier variantIdentifier:@"thumbnail"];
	
	[self _setImage:scaledImage];
}



- (void)setThumbnailImageURL:(NSURL *)imageURL
{
	if ([_imageURL isEqualToURL:imageURL])
	{
		return;
	}
	
	_imageURL = imageURL;
	
	NSString *imageIdentifier = [imageURL lastPathComponent];
    NSLog(@"imageIdentifier : %@", imageIdentifier);
	
	// check if we have a cached version
	DTImageCache *imageCache = [DTImageCache sharedCache];
	UIImage *thumbnail = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:@"thumbnail"];
	
	if (thumbnail)
	{
		[self _setImage:thumbnail];
		
		return;
	}
	
	// need to load it
	UIImage *image = [[DTDownloadCache sharedInstance] cachedImageForURL:imageURL option:DTDownloadCacheOptionLoadIfNotCached completion:^(NSURL *URL, UIImage *image, NSError *error) {
		
		if (error)
		{
			DTLogError(@"Error loading image %@", [error localizedDescription]);
		}
		else
		{
			[imageCache addImage:image forUniqueIdentifier:imageIdentifier variantIdentifier:nil];
         
         [self _setImage:image];
		}
	}];
	
	if (image)
	{
      [self _setImage:image];
	}
}

- (void)setImageURL:(NSURL *)imageURL
{
	if ([_imageURL isEqualToURL:imageURL])
	{
		return;
	}
	
	_imageURL = imageURL;
	
	NSString *imageIdentifier = [imageURL lastPathComponent];
	
	// check if we have a thumbnail
	
	DTImageCache *imageCache = [DTImageCache sharedCache];
	UIImage *thumbnail = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:@"thumbnail"];
	
	if (thumbnail)
	{
		[self _setImage:thumbnail];
		
		return;
	}
	
	// get the original

	UIImage *originalImage = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:nil];
	
	if (originalImage)
	{
		
		[self _prepareAndStoreThumbnailForImage:originalImage];
		
		return;
	}
		
	// need to load it
	

	UIImage *image = [[DTDownloadCache sharedInstance] cachedImageForURL:imageURL option:DTDownloadCacheOptionLoadIfNotCached completion:^(NSURL *URL, UIImage *image, NSError *error) {
		
		if (error)
		{
			DTLogError(@"Error loading image %@", [error localizedDescription]);
		}
		else
		{
			[imageCache addImage:image forUniqueIdentifier:imageIdentifier variantIdentifier:nil];

			[self _prepareAndStoreThumbnailForImage:image];
		}
	}];
	
	if (image)
	{
		[self _prepareAndStoreThumbnailForImage:image];
	}
}

@end
