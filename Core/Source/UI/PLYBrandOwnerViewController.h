//
//  PLYBrandOwnerViewController.h
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYSearchableTableViewController.h"

/**
 View Controller which displays brand suggestions for a GTIN
 */
@interface PLYBrandOwnerViewController : PLYSearchableTableViewController

/**
 The GTIN to base brand suggestions on
 */
@property (nonatomic, copy) NSString *GTIN;

@end
