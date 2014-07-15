//
//  ProductImageCollectionViewCell.h
//  PL
//
//  Created by Oliver Drobnik on 25.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PLYImage.h"

@interface ProductImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak)   IBOutlet UIImageView *imageView;
@property (nonatomic, strong) PLYImage *imageMetadata;

- (void) loadImageForMetadata:(PLYImage *)_metadata withSize:(CGSize)_size crop:(BOOL)_crop;

@end
