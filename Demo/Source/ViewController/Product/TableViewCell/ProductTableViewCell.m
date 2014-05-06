//
//  ProductTableViewCell.m
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "ProductTableViewCell.h"
#import "PLYServer.h"
#import "PLYProductImage.h"

#import "DTImageCache.h"
#import "DTDownloadCache.h"
#import "DTBlockFunctions.h"
#import "DTLog.h"

@implementation ProductTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) setProduct:(PLYProduct *)product{
    if([_product isEqual:product]){
        return;
    }
    
    _product = product;
    
    [self updateCell];
}

-(void) updateCell{
    _productImage.hidden = true;
    
    [_productName setText:_product.name];
    
    if(_product.brandName && ![_product.brandName isKindOfClass:[NSNull class]]) {
        [_productBrand setText:_product.brandName];
    }
    
    [_productLanguage setText:_product.language];
    
    [self loadMainImage];
}

- (void) loadMainImage{
    NSString *gtin = _product.gtin;
    
    if (!gtin)
	{
		return;
	}
	
	[[PLYServer sharedPLYServer] getImagesForGTIN:gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            NSArray *images = result;
            
            if(images != nil && images.count > 0){
                
                PLYProductImage *imageMeta = images[0];
                
                // Check if _product has changed since request
                if(![_product.gtin isEqualToString:imageMeta.gtin])
                    return;
                
                int imageSize = _productImage.frame.size.width*[[UIScreen mainScreen] scale];
                
                NSURL *imageURL = [NSURL URLWithString:[imageMeta getUrlForWidth:imageSize andHeight:imageSize crop:true]];
                
                NSString *imageIdentifier = [imageURL lastPathComponent];
                NSLog(@"imageIdentifier : %@", imageIdentifier);
                
                // check if we have a cached version
                DTImageCache *imageCache = [DTImageCache sharedCache];
                
                // TODO: We should also have the width and height as parameter, otherwise we could receive an image which has not the correct size.
                UIImage *thumbnail = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:@"thumbnail"];
                
                // Check if _product has changed since request
                if(![_product.gtin isEqualToString:imageMeta.gtin])
                    return;
                
                if (thumbnail)
                {
                    [_productImage setImage:thumbnail];
                    
                    return;
                }
                
                // need to load it
                UIImage *image = [[DTDownloadCache sharedInstance] cachedImageForURL:imageURL option:DTDownloadCacheOptionLoadIfNotCached completion:^(NSURL *URL, UIImage *image, NSError *error) {
                    
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        if (error)
                        {
                            DTLogError(@"Error loading image %@", [error localizedDescription]);
                        }
                        else
                        {
                            [imageCache addImage:image forUniqueIdentifier:imageIdentifier variantIdentifier:nil];
                            
                            // Check if _product has changed since request
                            if(![_product.gtin isEqualToString:imageMeta.gtin])
                                return;
                            
                            [_productImage setImage:image];
                        }
                    });
                }];
                
                if (image)
                {
                    [_productImage setImage:image];
                }
                
            } else {
                [_productImage setImage:[UIImage imageNamed:@"no_image.png"]];
            }
            
            _productImage.hidden = false;
		});
	}];
}

@end
