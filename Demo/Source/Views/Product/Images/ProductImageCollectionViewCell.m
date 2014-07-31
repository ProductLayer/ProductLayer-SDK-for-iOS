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

- (void)_setImage:(UIImage *)image  forMetadata:(PLYImage *)_metadata
{
    /* Only set image if the image for the metadata is the valid one.
     * Needed because the Cell is re-used and it can happen, that the
     * current valid image takes longer to load than the previous already invalid one.
     */
    if([_metadata isEqual:_imageMetadata]){
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            self.imageView.image = image;
        });
    }
}

- (void) loadImageForMetadata:(PLYImage *)_metadata withSize:(CGSize)_size crop:(BOOL)_crop{
    NSString *imageURLString = [_metadata getUrlForWidth:_size.width andHeight:_size.height crop:_crop];
    
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    
    if ([_imageURL isEqualToURL:imageURL])
	{
		return;
	}
    
	_imageMetadata = _metadata;
	_imageURL = imageURL;
    
	NSString *imageIdentifier = [imageURL lastPathComponent];
	
	// check if we have a thumbnail
	
	DTImageCache *imageCache = [DTImageCache sharedCache];
    
    NSString *variantIdentifier = [NSString stringWithFormat:@"%dx%d_%d",(int)_size.width,(int)_size.height,_crop];
    
    if(!imageIdentifier)
        return;
    
	UIImage *image = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:variantIdentifier];
    
	if (image)
	{
		[self _setImage:image forMetadata:_metadata];
		
		return;
	}
	
	// need to load it
	image = [[DTDownloadCache sharedInstance] cachedImageForURL:imageURL option:DTDownloadCacheOptionLoadIfNotCached completion:^(NSURL *URL, UIImage *image, NSError *error) {
		
		if (error)
		{
			DTLogError(@"Error loading image %@", [error localizedDescription]);
		}
		else
		{
			[imageCache addImage:image forUniqueIdentifier:imageIdentifier variantIdentifier:variantIdentifier];
            
            [self _setImage:image forMetadata:_metadata];
		}
	}];
	
	if (image)
	{
        [self _setImage:image forMetadata:_metadata];
	}
}

@end
