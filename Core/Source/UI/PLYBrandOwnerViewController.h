//
//  PLYBrandOwnerViewController.h
//  PL
//
//  Created by Oliver Drobnik on 16/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYSearchableTableViewController.h"

@class PLYBrandOwnerViewController;

@protocol PLYBrandOwnerViewController <NSObject>

@optional
- (void)brandPickerDidChangeSelection:(PLYBrandOwnerViewController *)categoryPicker;
@end

/**
 View Controller which displays brand suggestions for a GTIN
 */
@interface PLYBrandOwnerViewController : PLYSearchableTableViewController

/**
 The GTIN to base brand suggestions on
 */
@property (nonatomic, copy) NSString *GTIN;

/**
 The name of the brand
 */
@property (nonatomic, copy) NSString *selectedBrandName;

/**
 The name of the brand owner
 */
@property (nonatomic, copy) NSString *selectedBrandOwnerName;


/**
 Delegate to inform about changes in selection
 */
@property (nonatomic, weak) id <PLYBrandOwnerViewController>delegate;

@end
