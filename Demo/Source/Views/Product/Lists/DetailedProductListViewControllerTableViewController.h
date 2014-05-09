//
//  DetailedProductListViewControllerTableViewController.h
//  PL
//
//  Created by René Swoboda on 05/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@class PLYList;

@interface DetailedProductListViewControllerTableViewController : ProductLayerViewController

@property (nonatomic, strong) PLYList *list;

@end
