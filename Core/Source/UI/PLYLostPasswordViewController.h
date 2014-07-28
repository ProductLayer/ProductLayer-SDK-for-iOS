//
//  PLYLostPasswordViewController.h
//  PL
//
//  Created by Oliver Drobnik on 28/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYViewController.h"

@class PLYTextField;

/**
 View Controller for requesting a new password to be sent to a ProductLayer user
 */
@interface PLYLostPasswordViewController : PLYViewController

/**
 Text field for entering the email address
 */
@property (nonatomic, strong) PLYTextField *emailField;

@end
