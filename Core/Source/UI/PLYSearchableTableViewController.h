//
//  PLYSearchableTableViewController.h
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLYSearchableTableViewController : UITableViewController <UISearchResultsUpdating>

/**
 The search controller to be used by the receiver
 */
@property (nonatomic, readonly) UISearchController *searchController;

@end
