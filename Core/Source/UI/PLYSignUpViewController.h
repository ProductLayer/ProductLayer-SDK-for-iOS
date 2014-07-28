//
//  PLYSignUpViewController.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/16/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYViewController.h"

@class PLYTextField;

/**
 View Controller for signing up users to ProductLayer
 */
@interface PLYSignUpViewController : PLYViewController

/**
 Text field for entering the nickname
 */
@property (nonatomic, strong) PLYTextField *nameField;

/**
 Text field for entering the email address
 */
@property (nonatomic, strong) PLYTextField *emailField;

@end

