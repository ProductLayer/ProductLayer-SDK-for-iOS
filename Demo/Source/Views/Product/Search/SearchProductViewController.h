//
//  SearchProductViewController.h
//  PL
//
//  Created by Oliver Drobnik on 23/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@class PLYServer;

@interface SearchProductViewController : ProductLayerViewController

@property (weak, nonatomic) IBOutlet UISearchBar *productSearchBar;

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

@end
