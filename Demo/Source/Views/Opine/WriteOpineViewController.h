//
//  WriteOpineViewController.h
//  PL
//
//  Created by René Swoboda on 30/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"
#import "LocalePickerView.h"
#import "PLYEntity.h"

@interface WriteOpineViewController : ProductLayerViewController <LocalePickerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *gtinTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

@property (weak, nonatomic) IBOutlet UITextField *localeTextField;
@property (weak, nonatomic) IBOutlet LocalePickerView *localePicker;
@property (nonatomic) bool localePickerIsShowing;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;

- (IBAction)save:(id)sender;

@property (nonatomic, strong) PLYEntity* parent;

@end
