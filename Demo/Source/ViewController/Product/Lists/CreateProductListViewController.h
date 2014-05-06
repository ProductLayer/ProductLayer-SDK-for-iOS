//
//  CreateProductListViewController.h
//  PL
//
//  Created by René Swoboda on 03/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LocalizableStringPicker.h"

@interface CreateProductListViewController : UITableViewController <LocalizableStringPickerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *titleTextfield;
@property (nonatomic, weak) IBOutlet UITextView *descriptionTextview;
@property (nonatomic, weak) IBOutlet UITextField *listTypeTextfield;
@property (weak, nonatomic) IBOutlet LocalizableStringPicker *listTypePicker;
@property (nonatomic) bool listTypePickerIsShowing;

@property (nonatomic, weak) IBOutlet UITextField *sharingTypeTextfield;
@property (weak, nonatomic) IBOutlet LocalizableStringPicker *sharingTypePicker;
@property (nonatomic) bool sharingTypePickerIsShowing;

- (IBAction) createProductList:(id)sender;

@end
