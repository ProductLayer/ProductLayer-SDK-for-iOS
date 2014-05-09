//
//  SignUpViewController.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@interface SignUpViewController : ProductLayerViewController

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;

- (IBAction)nicknameChanged:(id)sender;
- (IBAction)emailChanged:(id)sender;

- (IBAction)save:(id)sender;

- (void)_updateSaveButtonState;


@end
