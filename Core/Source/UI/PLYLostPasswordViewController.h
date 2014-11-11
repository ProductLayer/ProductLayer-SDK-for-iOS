//
//  PLYLostPasswordViewController.h
//  PL
//
//  Created by Oliver Drobnik on 28/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

@class PLYLostPasswordViewController, PLYTextField, PLYUser;

/**
 Protocol for informing a delegate about the result of a user requesting for his password to be reset.
 */
@protocol PLYLostPasswordViewControllerDelegate <NSObject>
@optional

/**
 Called if the server reported that the user account with the entered email address existed and a new password was sent
 @param lostPasswordViewController The view controller sending the message
 @param user The `PLYUser` for which a new password was requested
 */
- (void)lostPasswordViewController:(PLYLostPasswordViewController *)lostPasswordViewController didRequestNewPasswordForUser:(PLYUser *)user;
@end


/**
 View Controller for requesting a new password to be sent to a ProductLayer user
 */
@interface PLYLostPasswordViewController : UIViewController

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
