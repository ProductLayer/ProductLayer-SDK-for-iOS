//
//  EditProductViewController.h
//  PL
//
//  Created by Oliver Drobnik on 23/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductLayer.h"
#import "LocalePickerView.h"
#import "PLYProduct.h"

@interface EditProductViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, LocalePickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *productNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *vendorTextField;


@property (weak, nonatomic) IBOutlet UITextField *gtinTextField;

@property (weak, nonatomic) IBOutlet UITextField *localeTextField;
@property (weak, nonatomic) IBOutlet LocalePickerView *localePicker;
@property (nonatomic) bool localePickerIsShowing;

@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (nonatomic, strong) NSDictionary *categories;
@property (nonatomic) bool categoryPickerIsShowing;

- (IBAction)save:(id)sender;
- (IBAction) cancel:(id)sender;

@property (nonatomic, strong) PLYProduct *product;

@end
