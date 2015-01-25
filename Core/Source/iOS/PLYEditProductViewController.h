//
//  PPLEditProductViewController.h
//  ProductLayer
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYModalTableViewController.h"

@class PLYProduct;

@interface PLYEditProductViewController : PLYModalTableViewController

@property (nonatomic, copy) PLYProduct *product;

@end
