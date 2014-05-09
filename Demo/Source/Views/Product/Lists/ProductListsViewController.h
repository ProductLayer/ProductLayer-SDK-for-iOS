//
//  ProductListsViewController.h
//  PL
//
//  Created by René Swoboda on 03/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@class PLYUser;
@class PLYList;
@class PLYProduct;

@interface ProductListsViewController : ProductLayerViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (nonatomic) BOOL addProductView;
@property (nonatomic) PLYProduct *product;

- (void) loadProductListsForUser:(PLYUser *)user andType:(NSString *)type;

@end
