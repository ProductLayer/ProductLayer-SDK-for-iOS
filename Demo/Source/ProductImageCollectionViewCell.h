//
//  ProductImageCollectionViewCell.h
//  PL
//
//  Created by Oliver Drobnik on 25.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

/*
 Prepares a thumbnail if necessary for the image
 */
- (void)setImageURL:(NSURL *)imageURL;

/*
 Simply sets the image or loads it if necessary
 */
- (void)setThumbnailImageURL:(NSURL *)imageURL;

@end
