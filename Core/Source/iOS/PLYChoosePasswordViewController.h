//
//  PLYChoosePasswordViewController.h
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 20/11/15.
//  Copyright © 2015 Cocoanetics. All rights reserved.
//

@class PLYChoosePasswordViewController, PLYTextField, PLYUser;


/**
 Protocol for informing the delegate about result of user setting a password
 */
@protocol PLYChoosePasswordViewControllerDelegate <NSObject>
@optional

/**
 Called if the server reported that the passward was correctly set
 @param choosePasswordViewController The view controller sending the message
 @param user The user for which the password was changed
 */
- (void)choosePasswordViewControllerDidFinish:(PLYChoosePasswordViewController *)choosePasswordViewController forUser:(PLYUser *)user;
@end


/**
 View controller that lets a user set a password with a token he received by e-mail.
 */
@interface PLYChoosePasswordViewController : UIViewController

/**
 @name Properties
 */

/**
 Text field for entering the nickname
 */
@property (nonatomic, strong) PLYTextField *passwordField;


/**
 The password reset token
 */
@property (nonatomic, copy) NSString *resetToken;

/**
 Delegate to inform about result of the lost password dialog
 */
@property (nonatomic, weak) id <PLYChoosePasswordViewControllerDelegate> delegate;

@end
