//
//  ProductImageView.h
//  PL
//
//  Created by René Swoboda on 30/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PLYProductImage.h"

@interface ProductImageView : UIImageView

@property (nonatomic, strong) PLYProductImage *productMetadata;

@end
