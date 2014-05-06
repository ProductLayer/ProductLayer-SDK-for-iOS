//
//  ProductImageCollectionViewCell.h
//  PL
//
//  Created by Oliver Drobnik on 25.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PLYProductImage.h"

@interface ProductImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak)   IBOutlet UIImageView *imageView;
@property (nonatomic, strong) PLYProductImage *imageMetadata;

- (void) loadImageForMetadata:(PLYProductImage *)_metadata withSize:(CGSize)_size crop:(BOOL)_crop;

@end
