//
//  ProductViewController.h
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLYServer.h"
#import "EditableCell.h"

#import "PLYProduct.h"
#import "PLYProductImage.h"

@interface ProductViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productBrand;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;

@property (weak, nonatomic) IBOutlet EditableCell *productCharacteristics;
@property (weak, nonatomic) IBOutlet EditableCell *productNutritious;

@property (nonatomic, strong) PLYProduct *product;

- (void) setProduct:(PLYProduct *)product;

@end
