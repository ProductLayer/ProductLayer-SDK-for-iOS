//
//  OpineTableViewCell.m
//  PL
//
//  Created by René Swoboda on 30/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "OpineTableViewCell.h"

#import "DTBlockFunctions.h"
#import "DTDownloadCache.h"
#import "DTImageCache.h"
#import "DTLog.h"

#import "ProductLayer.h"

@implementation OpineTableViewCell

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

- (void) setOpine:(PLYOpine *)opine{
    if([_opine isEqual:opine]){
        return;
    }
    
    _opine = opine;
    
    [self updateCell];
}

-(void) updateCell{
    _productImage.hidden = YES;
    
    [_bodyLabel setText:_opine.text];
    [_authorLabel setText:_opine.createdBy.nickname];
    
    
    [self loadMainImage];
}

- (void) loadMainImage{
    NSString *gtin = _opine.GTIN;
    
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
            
            _productImage.hidden = NO;
		});
	}];
}

@end
