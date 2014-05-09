//
//  ProductViewController.h
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableCell.h"
#import "EditProductViewController.h"
#import "ProductLayerViewController.h"

#import "ProductLayer.h"

@interface ProductViewController : ProductLayerViewController <ProductUpdateDelegate>

@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productBrand;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *localeLabel;

@property (weak, nonatomic) IBOutlet UIButton *addToListButton;

@property (weak, nonatomic) IBOutlet EditableCell *productCharacteristics;
@property (weak, nonatomic) IBOutlet EditableCell *productNutritious;

@property (nonatomic, strong) PLYProduct *product;

- (void) loadProductWithGTIN:(NSString *)_gtin;
- (void) setProduct:(PLYProduct *)product;

@end
