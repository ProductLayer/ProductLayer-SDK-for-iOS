//
//  PLYLoginViewController.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYViewController.h"

@class PLYTextField;

@interface PLYLoginViewController : PLYViewController

/**
 Text field for entering the nickname
 */
@property (nonatomic, strong) PLYTextField *nameField;

/**
 Text field for entering the password
 */
@property (nonatomic, strong) PLYTextField *passwordField;

@end
