//
//  PLYSignUpViewController.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/16/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

@class PLYSignUpViewController, PLYTextField, PLYUser;


/**
 Protocol for informing the delegate about result of user sign up
 */
@protocol PLYSignUpViewControllerDelegate <NSObject>
@optional

/**
 Called if the server reported that the user account with the entered email address existed and a new password was sent
 @param lostPasswordViewController The view controller sending the message
 @param user The PLYUser object for which a sign up was performed
 */
- (void)signUpViewController:(PLYSignUpViewController *)lostPasswordViewController didSignUpNewUser:(PLYUser *)user;
@end


/**
 View Controller for signing up users to ProductLayer
 */
@interface PLYSignUpViewController : UIViewController

/**
 @name Properties
 */

/**
 Text field for entering the nickname
 */
@property (nonatomic, strong) PLYTextField *nameField;

/**
 Text field for entering the email address
 */
@property (nonatomic, strong) PLYTextField *emailField;

/**
 Delegate to inform about result of the lost password dialog
 */
@property (nonatomic, weak) id <PLYSignUpViewControllerDelegate> delegate;

@end

