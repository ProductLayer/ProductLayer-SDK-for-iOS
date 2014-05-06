//
//  ProductImageViewController.h
//  PL
//
//  Created by Oliver Drobnik on 25.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

@interface ProductImageViewController : UICollectionViewController

@property (nonatomic, strong) NSString *gtin;
@property (nonatomic, strong) NSArray *images;

- (void) loadLastImages;
- (void) loadImagesFromGtin:(NSString *)gtin;


- (IBAction)addImageToProduct:(id)sender;

@end
