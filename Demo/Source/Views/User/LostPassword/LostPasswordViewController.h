//
//  LostPasswordViewController.h
//  PL
//
//  Created by René Swoboda on 07/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductLayerViewController.h"

@interface LostPasswordViewController : ProductLayerViewController

@property (nonatomic, weak) IBOutlet UITextField *emailTextfield;

- (IBAction) requestNewPassword:(id)sender;

@end
