//
//  ReviewTableViewCell.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "ReviewTableViewCell.h"

#import "DTBlockFunctions.h"
#import "DTDownloadCache.h"
#import "DTImageCache.h"
#import "DTLog.h"

#import "PLYAuditor.h"
#import "PLYServer.h"
#import "PLYProductImage.h"

@implementation ReviewTableViewCell

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

- (void) setReview:(PLYReview *)review{
    if([_review isEqual:review]){
        return;
    }
    
    _review = review;
    
    [self updateCell];
}

-(void) updateCell{
    _productImage.hidden = true;
    
    [_subjectLabel setText:_review.subject];
    [_bodyLabel setText:_review.body];
    [_authorLabel setText:_review.createdBy.userNickname];
    
    
    [self loadMainImage];
}

- (void) loadMainImage{
    NSString *gtin = _review.gtin;
    
    if (!gtin)
	{
		return;
	}
	
	[[PLYServer sharedPLYServer] getImagesForGTIN:gtin completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            NSArray *images = result;
            
            if(images != nil && images.count > 0){
                
                PLYProductImage *imageMeta = images[0];
                
                int imageSize = _productImage.frame.size.width*2;
                
                NSURL *imageURL = [NSURL URLWithString:[imageMeta getUrlForWidth:imageSize andHeight:imageSize crop:@"true"]];
                
                NSString *imageIdentifier = [imageURL lastPathComponent];
                NSLog(@"imageIdentifier : %@", imageIdentifier);
                
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
            
            _productImage.hidden = false;
		});
	}];
}

@end
