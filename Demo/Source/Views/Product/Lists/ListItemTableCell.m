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
    if(![_listItem.gtin isEqualToString:listItem.gtin]){
        // Load product data
        
        [[PLYServer sharedPLYServer] performSearchForGTIN:listItem.gtin language:nil completion:^(id result, NSError *error) {
                if (error)
                {
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        _productNameLabel.text = listItem.gtin;
                    });
                }
                else
                {
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        [self loadMainImage];
                    });
                    
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
    _qtyLabel.text = [_listItem.qty stringValue];
    
    if(_product){
        _productNameLabel.text = _product.name;
    } else {
        // Couldn't load the product for the list item. Show gtin
        _productNameLabel.text = _listItem.gtin;
    }
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
                
                // check if we have a cached version
                DTImageCache *imageCache = [DTImageCache sharedCache];
                
                // TODO: We should also have the width and height as parameter, otherwise we could receive an image which has not the correct size.
                UIImage *thumbnail = [imageCache imageForUniqueIdentifier:imageIdentifier variantIdentifier:@"thumbnail"];
                
                // Check if _product has changed since request
                if(![_product.gtin isEqualToString:imageMeta.gtin])
                    return;
                
                if (thumbnail)
                {
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        [_productImage setImage:thumbnail];
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
                            if(![_product.gtin isEqualToString:imageMeta.gtin])
                                return;
                            
                            [_productImage setImage:image];
                        }
                    });
                }];
                
                if (image)
                {
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        [_productImage setImage:image];
                    });
                }
                
            } else {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    [_productImage setImage:[UIImage imageNamed:@"no_image.png"]];
                });
            }
            
            _productImage.hidden = false;
		});
	}];
}

- (PLYProduct *) getProduct{
    return _product;
}

@end
