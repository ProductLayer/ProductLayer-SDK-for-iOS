//
//  PLYLoginViewController.h
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

@class PLYTextField;

/**
 Completion handler for Login
 */
typedef void (^PLYLoginCompletion)(BOOL success);

/**
 View Controller for logging in users to Product Layer. Wrap into a `UINavigationController` for presenting it modally
 */

@interface PLYLoginViewController : UIViewController

/**
 @name Properties
 */

/**
 Explanation text what the benefits of logging in will be. If left `nil` then a default test is used.
*/
@property (nonatomic, copy) NSString *explanationText;

/**
 Text field for entering the nickname
 */
@property (nonatomic, strong) PLYTextField *nameField;

/**
 Text field for entering the password
 */
@property (nonatomic, strong) PLYTextField *passwordField;

/**
 Completion handler for the login operation, gets called after dismissal animation following successful login
 */
@property (nonatomic, copy) PLYLoginCompletion loginCompletion;


/**
 @name UI
 */

/**
 Presents the login UI flow and once the user successfully logs in or cancels performs the block
 @param explanation The explanation text describing the benefits of logging in
 @param completion The blog to execute after the login flow
 */
+ (void)presentLoginWithExplanation:(NSString *)explanation completion:(PLYLoginCompletion)completion;


@end
