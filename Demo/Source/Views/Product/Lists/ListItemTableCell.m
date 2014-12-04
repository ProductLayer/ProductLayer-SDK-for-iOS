//
//  ListItemTableCell.m
//  PL
//
//  Created by René Swoboda on 05/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "ListItemTableCell.h"

#import "ProductLayer.h"
#import "AppSettings.h"

#import "DTBlockFunctions.h"
#import "DTImageCache.h"
#import "DTDownloadCache.h"
#import "DTLog.h"

@implementation ListItemTableCell {
    PLYProduct *_product;
}

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

- (void) setListItem:(PLYListItem *)listItem{
    if(![_listItem.GTIN isEqualToString:listItem.GTIN]){
        // Load product data
        
        [[PLYServer sharedServer] performSearchForGTIN:listItem.GTIN language:nil completion:^(id result, NSError *error) {
                if (error)
                {
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        _productNameLabel.text = listItem.GTIN;
                    });
                }
                else
                {
                    if ([result count] == 1) {
                        _product = result[0];
                    } else if ([result count] > 1){
                        
                        PLYProduct *defaultLocaleProduct;
                        
                        _product = nil;
                        
                        for(PLYProduct *product in result){
                            // Search for current locale
                            if([product.language isEqualToString:[AppSettings currentAppLocale].localeIdentifier]){
                                _product = product;
                                break;
                            } else if([product.language isEqualToString:@"en"] || [product.language rangeOfString:@"en_"].location != NSNotFound){
                                defaultLocaleProduct = product;
                            }
                        }
                        
                        if(!_product){
                            _product = defaultLocaleProduct;
                        }
                    }
                    
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        [self loadMainImage];
                        [self updateCell];
                    });
                }
            }];
    }
    
    _listItem = listItem;
    
    [self updateCell];
}

- (void) updateCell{
    _listNoteLabel.text = _listItem.note;
    _qtyLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)_listItem.quantity];
    
    if(_product){
        _productNameLabel.text = _product.name;
    } else {
        // Couldn't load the product for the list item. Show gtin
        _productNameLabel.text = _listItem.GTIN;
    }
}

- (void) loadMainImage{
    NSString *gtin = _product.GTIN;
    
    if (!gtin)
	{
		return;
	}
	
	[[PLYServer sharedServer] getImagesForGTIN:gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            NSArray *images = result;
            
            if(images != nil && images.count > 0){
                
                PLYImage *imageMeta = images[0];
                
                int imageSize = _productImage.frame.size.width*[[UIScreen mainScreen] scale];
                
                NSURL *imageURL = [NSURL URLWithString:[imageMeta getUrlForWidth:imageSize andHeight:imageSize crop:true]];
                
                NSString *imageIdentifier = [imageURL lastPathComponent];
                
                // check if we have a cached version
                DTImageCache *imageCache = [DTImageCache sharedCache];
                
                // TODO: We should also have the width and height as parameter, otherwise we could receive an image which has not the correct size.
                UIImage *thumbnail = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:@"thumbnail"];
                
                // Check if _product has changed since request
                if(![_product.GTIN isEqualToString:imageMeta.GTIN])
                    return;
                
                if (thumbnail)
                {
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        [_productImage setImage:thumbnail];
                        _productImage.hidden = NO;
                    });

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
                            if(![_product.GTIN isEqualToString:imageMeta.GTIN])
                                return;
                            
                            [_productImage setImage:image];
                            _productImage.hidden = NO;
                        }
                    });
                }];
                
                if (image)
                {
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        [_productImage setImage:image];
                        _productImage.hidden = NO;
                    });
                }
                
            } else {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    [_productImage setImage:[UIImage imageNamed:@"no_image.png"]];
                    _productImage.hidden = NO;
                });
            }
            
            
		});
	}];
}

- (PLYProduct *) getProduct{
    return _product;
}

@end
