//
//  PLYBrandPickerViewController.h
//  PL
//
//  Created by Oliver Drobnik on 21/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYBrandPickerViewController;

/**
 Protocol for delegates of PLYBrandPickerViewController
 */
@protocol PLYBrandPickerViewControllerDelegate <NSObject>

@optional
/**
 Called if the user selects a row
 @param brandPicker The sender of the message
 */
- (void)brandPickerDidSelect:(PLYBrandPickerViewController *)brandPicker;

@end

/**
 View controller for selecting a brand, optinally containing suggestions by GTIN.
 */
@interface PLYBrandPickerViewController : UITableViewController

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
@property (nonatomic, weak) id<PLYBrandPickerViewControllerDelegate> delegate;

@end
