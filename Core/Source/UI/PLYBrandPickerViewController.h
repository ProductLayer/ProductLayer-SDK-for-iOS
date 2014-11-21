//
//  PLYBrandPickerViewController.h
//  PL
//
//  Created by Oliver Drobnik on 21/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYBrandPickerViewController;

@protocol PLYBrandPickerViewControllerDelegate <NSObject>

@optional
- (void)brandPickerDidSelect:(PLYBrandPickerViewController *)brandPicker;
@end

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
