//
//  WriteReviewViewController.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LocalePickerView.h"

@interface WriteReviewViewController : UITableViewController <LocalePickerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *gtinTextField;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UITextField *ratingTextField;

@property (weak, nonatomic) IBOutlet UITextField *localeTextField;
@property (weak, nonatomic) IBOutlet LocalePickerView *localePicker;
@property (nonatomic) bool localePickerIsShowing;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;

- (IBAction)save:(id)sender;

@property (nonatomic, strong) NSString *gtin;

@end
