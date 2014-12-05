//
//  PLYSearchableTableViewController.h
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

/**
 A table view controller with an additional search bar
 */

@interface PLYSearchableTableViewController : UITableViewController <UISearchResultsUpdating>

/**
 The search controller to be used by the receiver
 */
@property (nonatomic, readonly) UISearchController *searchController;


/**
 The array of search terms currently in the search text field
 */
- (NSArray *)currentSearchTerms;

@end


// private interface for subclasses
@interface PLYSearchableTableViewController ()
- (BOOL)_text:(NSString *)text containsAllTerms:(NSArray *)terms;
- (NSAttributedString *)_attributedStringForText:(NSString *)text withSearchTermsMarked:(NSArray *)terms;
@end
