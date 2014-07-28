//
//  PLYLostPasswordViewController.h
//  PL
//
//  Created by Oliver Drobnik on 28/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYViewController.h"

@class PLYLostPasswordViewController, PLYTextField, PLYUser;

@protocol PLYLostPasswordViewControllerDelegate <NSObject>
@optional

/**
 Called if the server reported that the user account with the entered email address existed and a new password was sent
 */
- (void)lostPasswordViewController:(PLYLostPasswordViewController *)lostPasswordViewController didRequestNewPasswordForUser:(PLYUser *)user;
@end


/**
 View Controller for requesting a new password to be sent to a ProductLayer user
 */
@interface PLYLostPasswordViewController : PLYViewController

/**
 @name Properties
 */

/**
 Text field for entering the email address
 */
@property (nonatomic, strong) PLYTextField *emailField;

/**
 Delegate to inform about result of the lost password dialog
 */
@property (nonatomic, weak) id <PLYLostPasswordViewControllerDelegate> delegate;

@end
