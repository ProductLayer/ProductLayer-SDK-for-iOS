//
//  SettingsViewController.h
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

#import "LocalePickerView.h"

@interface SettingsViewController : ProductLayerViewController <LocalePickerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet UITextField *localeTextField;
@property (weak, nonatomic) IBOutlet LocalePickerView *localePicker;
@property (nonatomic) bool localePickerIsShowing;

@end
