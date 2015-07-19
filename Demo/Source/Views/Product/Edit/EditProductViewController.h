//
//  EditProductViewController.h
//  PL
//
//  Created by Oliver Drobnik on 23/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ProductLayerSDK.h"
#import "LocalePickerView.h"
#import "PLYProduct.h"
#import "ProductLayerViewController.h"
#import "LocalizableStringPicker.h"

@protocol ProductUpdateDelegate <NSObject>
- (void) productUpdated:(PLYProduct *)product;
@end

@interface EditProductViewController : ProductLayerViewController <LocalePickerDelegate, LocalizableStringPickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *productNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *vendorTextField;

@property (weak, nonatomic) IBOutlet UITextField *gtinTextField;

@property (weak, nonatomic) IBOutlet UITextField *localeTextField;
@property (weak, nonatomic) IBOutlet LocalePickerView *localePicker;
@property (nonatomic) bool localePickerIsShowing;

@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;
@property (weak, nonatomic) IBOutlet LocalizableStringPicker *categoryPicker;
@property (nonatomic) bool categoryPickerIsShowing;

// delegate to inform about product changes
@property (nonatomic, weak) id <ProductUpdateDelegate> delegate;

- (IBAction)save:(id)sender;
- (IBAction) cancel:(id)sender;

@property (nonatomic, strong) PLYProduct *product;

@end
