//
//  SettingsViewController.h
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LocalePickerView.h"

@interface SettingsViewController : UITableViewController <LocalePickerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet UITextField *localeTextField;
@property (weak, nonatomic) IBOutlet LocalePickerView *localePicker;
@property (nonatomic) bool localePickerIsShowing;

@end
