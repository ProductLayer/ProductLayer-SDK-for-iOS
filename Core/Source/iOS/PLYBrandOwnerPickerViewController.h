//
//  PLYBrandOwnerPickerViewController.h
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 27.01.15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

@class PLYBrandOwnerPickerViewController;

/**
 Protocol for delegates of PLYBrandOwnerPickerViewController
 */
@protocol PLYBrandOwnerPickerViewControllerDelegate <NSObject>

@optional
/**
 Called if the user selects a row
 @param brandOwnerPicker The sender of the message
 */
- (void)brandOwnerPickerDidSelect:(PLYBrandOwnerPickerViewController *)brandOwnerPicker;

@end

/**
 View controller for selecting a brand owner, optinally containing suggestions by GTIN.
 */
@interface PLYBrandOwnerPickerViewController : UITableViewController

/**
 The GTIN to base brand suggestions on
 */
@property (nonatomic, copy) NSString *GTIN;

/**
 The name of the brand owner
 */
@property (nonatomic, copy) NSString *selectedBrandOwnerName;

/**
 Delegate to inform about changes in selection
 */
@property (nonatomic, weak) id<PLYBrandOwnerPickerViewControllerDelegate> delegate;

@end
