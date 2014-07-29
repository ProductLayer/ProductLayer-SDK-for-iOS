//
//  PLYLoginViewController.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYViewController.h"

@class PLYTextField;

/**
 View Controller for logging in users to Product Layer. Wrap into a `UINavigationController` for presenting it modally
 */

@interface PLYLoginViewController : PLYViewController

/**
 @name Properties
 */

/**
 Text field for entering the nickname
 */
@property (nonatomic, strong) PLYTextField *nameField;

/**
 Text field for entering the password
 */
@property (nonatomic, strong) PLYTextField *passwordField;

@end
