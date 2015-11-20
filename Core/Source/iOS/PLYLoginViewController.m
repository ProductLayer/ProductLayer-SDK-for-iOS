//
//  PLYLoginViewController.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/18/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYLoginViewController.h"
#import "PLYSignUpViewController.h"
#import "PLYLostPasswordViewController.h"
#import "UIViewController+ProductLayer.h"
#import "PLYNavigationController.h"

#import "PLYSocialAuthWebViewController.h"

#import "ProductLayerUI.h"

#import <DTFoundation/DTBlockFunctions.h>
#import <DTFoundation/DTLog.h>


// user default remembering last successful nickname
NSString * const LastLoggedInUserDefault = @"LastLoggedInUser";

@interface PLYLoginViewController () <PLYFormValidationDelegate, PLYLostPasswordViewControllerDelegate, PLYSignUpViewControllerDelegate, UITextFieldDelegate>

@end

@implementation PLYLoginViewController
{
	NSArray *_validators;
	
	UIBarButtonItem *_leftButton;
	UIBarButtonItem *_rightButton;
	
	UIButton *_facebookButton;
	UIButton *_twitterButton;
	
	UILabel *_explainLabel;
	
	BOOL _didTryWebCredential;
	BOOL _userDidPickWebCredential;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	NSMutableArray *validators = [NSMutableArray array];
	_explainLabel = [[UILabel alloc] init];
	_explainLabel.text = PLYLocalizedStringFromTable(@"PLY_LOGIN_EXPLAIN", @"UI", @"Explanation to show on login dialog");
	
	_explainLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_explainLabel.numberOfLines = 0;
	_explainLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[_explainLabel sizeToFit];
	[self.view addSubview:_explainLabel];
	
	PLYUserNameValidator *nameValidator = [PLYUserNameValidator validatorWithDelegate:self];
	[validators addObject:nameValidator];
	
	_nameField = [[PLYTextField alloc] initWithFrame:CGRectZero];
	_nameField.autocorrectionType = UITextAutocorrectionTypeNo;
	_nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_nameField.spellCheckingType = UITextSpellCheckingTypeNo;
	_nameField.placeholder = PLYLocalizedStringFromTable(@"PLY_NAME_PLACEHOLDER", @"UI", @"User Name Field Placeholder");
	_nameField.validator = nameValidator;
	_nameField.returnKeyType = UIReturnKeyNext;
	_nameField.delegate = self;
	_nameField.enablesReturnKeyAutomatically = YES;
	[self.view addSubview:_nameField];
	
	PLYUserNameValidator *passwordValidator = [PLYUserNameValidator validatorWithDelegate:self];
	[validators addObject:passwordValidator];
	
	_passwordField = [[PLYTextField alloc] initWithFrame:CGRectZero];
	_passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
	_passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_passwordField.spellCheckingType = UITextSpellCheckingTypeNo;
	_passwordField.secureTextEntry = YES;
	_passwordField.placeholder = PLYLocalizedStringFromTable(@"PLY_PASSWORD_PLACEHOLDER", @"UI", @"Password Field Placeholder");
	_passwordField.validator = passwordValidator;
	_passwordField.returnKeyType = UIReturnKeySend;
	_passwordField.delegate = self;
	_passwordField.enablesReturnKeyAutomatically = YES;
	[self.view addSubview:_passwordField];
	
	UIButton *lostPwButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[lostPwButton setTitle:PLYLocalizedStringFromTable(@"PLY_LOGIN_LOST_PASSWORD", @"UI", @"Link to lost password dialog")
					  forState:UIControlStateNormal];
	lostPwButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[lostPwButton addTarget:self action:@selector(showLostPassword:) forControlEvents:UIControlEventTouchUpInside];
	lostPwButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:lostPwButton];
	
	UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[signupButton setTitle:PLYLocalizedStringFromTable(@"PLY_LOGIN_CREATE_ACCOUNT", @"UI", @"Link to create new account dialog") forState:UIControlStateNormal];
	signupButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[signupButton addTarget:self action:@selector(showSignUp:) forControlEvents:UIControlEventTouchUpInside];
	signupButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:signupButton];
	
	_validators = [validators copy];
	
	NSString *facebookPath = [PLYResourceBundle() pathForResource:@"facebook-button" ofType:@"png"];
	UIImage *facebookIcon = [[UIImage imageWithContentsOfFile:facebookPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(facebookIcon!=nil, @"Missing Facebook icon in resource bundle");
	
	_facebookButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[_facebookButton addTarget:self action:@selector(signInWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
	_facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_facebookButton setTitle:PLYLocalizedStringFromTable(@"SIGN_IN_WITH_FACEBOOK", @"UI", @"Button for signing in with Facebook") forState:UIControlStateNormal];
	[_facebookButton setImage:facebookIcon forState:UIControlStateNormal];
	[self.view addSubview:_facebookButton];
	
	[self.view addConstraint:
	 [NSLayoutConstraint constraintWithItem:_facebookButton
											attribute:NSLayoutAttributeCenterX
											relatedBy:NSLayoutRelationEqual
												toItem:self.view
											attribute:NSLayoutAttributeCenterX
										  multiplier:1
											 constant:0]];
	
	NSString *twitterPath = [PLYResourceBundle() pathForResource:@"twitter-button" ofType:@"png"];
	UIImage *twitterIcon = [[UIImage imageWithContentsOfFile:twitterPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(twitterIcon!=nil, @"Missing Twitter icon in resource bundle");

	_twitterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[_twitterButton addTarget:self action:@selector(signInWithTwitter:) forControlEvents:UIControlEventTouchUpInside];
	_twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_twitterButton setTitle:PLYLocalizedStringFromTable(@"SIGN_IN_WITH_TWITTER", @"UI", @"Button for signing in with Twitter") forState:UIControlStateNormal];
	[_twitterButton setImage:twitterIcon forState:UIControlStateNormal];
	[self.view addSubview:_twitterButton];
	
	[self.view addConstraint:
	 [NSLayoutConstraint constraintWithItem:_twitterButton
											attribute:NSLayoutAttributeCenterX
											relatedBy:NSLayoutRelationEqual
												toItem:self.view
											attribute:NSLayoutAttributeCenterX
										  multiplier:1
											 constant:0]];
	
	id topGuide = [self topLayoutGuide];
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_nameField, _passwordField, topGuide,
																						lostPwButton, signupButton, _explainLabel,
																						_twitterButton, _facebookButton);
	NSArray *constraints1 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[_explainLabel]-[_nameField]-[_passwordField]-[lostPwButton]-[signupButton]-(50)-[_twitterButton]-(20)-[_facebookButton]"
														 options:0 metrics:nil views:viewsDictionary];
	NSArray *constraints2 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_nameField(300)]"
														 options:0 metrics:nil views:viewsDictionary];
	NSArray *constraints3 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_passwordField(300)]"
														 options:0 metrics:nil views:viewsDictionary];
	
	NSArray *constraints4 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_explainLabel(280)]"
														 options:0 metrics:nil views:viewsDictionary];

	[self.view addConstraints:constraints1];
	[self.view addConstraints:constraints2];
	[self.view addConstraints:constraints3];
	[self.view addConstraints:constraints4];
	
	[self.view addConstraint:
	 [NSLayoutConstraint constraintWithItem:_nameField
											attribute:NSLayoutAttributeCenterX
											relatedBy:NSLayoutRelationEqual
												toItem:self.view
											attribute:NSLayoutAttributeCenterX
										  multiplier:1
											 constant:0]];
	
	[self.view addConstraint:
	 [NSLayoutConstraint constraintWithItem:_passwordField
											attribute:NSLayoutAttributeCenterX
											relatedBy:NSLayoutRelationEqual
												toItem:self.view
											attribute:NSLayoutAttributeCenterX
										  multiplier:1
											 constant:0]];

	[self.view addConstraint:
	 [NSLayoutConstraint constraintWithItem:lostPwButton
											attribute:NSLayoutAttributeRight
											relatedBy:NSLayoutRelationEqual
												toItem:_passwordField
											attribute:NSLayoutAttributeRight
										  multiplier:1
											 constant:0]];
	
	[self.view addConstraint:
	 [NSLayoutConstraint constraintWithItem:signupButton
											attribute:NSLayoutAttributeRight
											relatedBy:NSLayoutRelationEqual
												toItem:_passwordField
											attribute:NSLayoutAttributeRight
										  multiplier:1
											 constant:0]];
	
	[self.view addConstraint:
	 [NSLayoutConstraint constraintWithItem:_explainLabel
											attribute:NSLayoutAttributeCenterX
											relatedBy:NSLayoutRelationEqual
												toItem:self.view
											attribute:NSLayoutAttributeCenterX
										  multiplier:1
											 constant:0]];
	
	[self.navigationController.view setTintColor:PLYBrandColor()];
	
	_leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = _leftButton;
	
	NSString *title = PLYLocalizedStringFromTable(@"PLY_LOGIN_RIGHT_BUTTON_TITLE", @"UI", @"Text for done button in login dialog");
	_rightButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
	_rightButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = _rightButton;
	
	NSString *backTitle = PLYLocalizedStringFromTable(@"PLY_LOGIN_SHORT_TITLE", @"UI", @"Short title used as back button from other view controllers going back to login");
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:backTitle style:UIBarButtonItemStylePlain target:nil action:NULL];
	
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboardTap:)];
	[self.view addGestureRecognizer:tap];
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (PLY_SUPPORTED_INTERFACE_ORIENTATIONS_RETURN_TYPE)supportedInterfaceOrientations
{
	return UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (![_nameField.text length])
	{
		_nameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:LastLoggedInUserDefault];
	}
	
	if ([_explanationText length])
	{
		_explainLabel.text = _explanationText;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (_didTryWebCredential)
	{
		return;
	}
	
	_didTryWebCredential = YES;
	
	SecRequestSharedWebCredential(CFSTR("prod.ly"), NULL, ^(CFArrayRef credentials, CFErrorRef error)
	{
		if (error != NULL)
		{
			DTLogError(@"Error requesting web credential: %@", [(__bridge NSError *)error localizedDescription]);
			return;
		}
		
		if (!CFArrayGetCount(credentials))
		{
			DTLogInfo(@"User did not have any shared web credentials or selected 'Not Now'");
			return;
		}
		
		NSDictionary *credential = [(__bridge NSArray *)credentials firstObject];
		
		NSString *userName = credential[(__bridge id)(kSecAttrAccount)];
		NSString *password = credential[(__bridge id)(kSecSharedPassword)];
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			self.nameField.text = userName;
			self.passwordField.text = password;
			
			_userDidPickWebCredential = YES;
			[self done:nil];
		});
	});
}

#pragma mark - Class Methods

+ (void)presentLoginWithExplanation:(NSString *)explanation completion:(PLYLoginCompletion)completion
{
	DTBlockPerformSyncOnMainThread(^{
		PLYLoginViewController *login = [[PLYLoginViewController alloc] init];
		login.explanationText = explanation;
		
		if (completion)
		{
			login.loginCompletion = completion;
		};
		
		PLYNavigationController *nav = [[PLYNavigationController alloc] initWithRootViewController:login];
		
		UIViewController *controllerForPresenting = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
		
		while (controllerForPresenting.presentedViewController)
		{
			controllerForPresenting = controllerForPresenting.presentedViewController;
		}
		
		[controllerForPresenting presentViewController:nav animated:YES completion:NULL];
	});
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

	[self dismissViewControllerAnimated:YES completion:^{
		if (_loginCompletion)
		{
			_loginCompletion(NO);
		}
	}];
}

- (void)_loginCompleteForUser:(PLYUser *)user
{
	UIBarButtonItem *check = [[UIBarButtonItem alloc] initWithTitle:@"👍" style:UIBarButtonItemStylePlain target:nil action:NULL];
	check.tintColor = self.navigationController.view.tintColor;
	self.navigationItem.rightBarButtonItem = check;
	
	// remember successful login for next time
	[[NSUserDefaults standardUserDefaults] setObject:user.nickname forKey:LastLoggedInUserDefault];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self dismissViewControllerAnimated:YES completion:^{
			if (_loginCompletion)
			{
				_loginCompletion(YES);
			}
		}];
	});
}

- (void)done:(id)sender
{
	if (![self _allFieldsValid])
	{
		DTLogError(@"Invalid event: Should not be able to execute done if not both user and password fields are value");
		return;
	}
	
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activity startAnimating];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
	
	[self.productLayerServer loginWithUser:_nameField.text password:_passwordField.text completion:^(id result, NSError *error) {
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			// restore right button
			self.navigationItem.rightBarButtonItem = _rightButton;
			
			if (error)
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PLYLocalizedStringFromTable(@"PLY_LOGIN_FAILED_TITLE", @"UI", @"Alert title when login fails")
																				message:[error localizedDescription]
																			  delegate:nil
																  cancelButtonTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title")
																  otherButtonTitles:nil];
				alert.tintColor = [UIColor redColor];
				[alert show];
				
				return;
			}
			else
			{
				if (!_userDidPickWebCredential)
				{
					// also save as shared web credential if possible
					SecAddSharedWebCredential(CFSTR("prod.ly"), (__bridge CFStringRef)(_nameField.text), (__bridge CFStringRef)(_passwordField.text), ^(CFErrorRef error) {
						
						if (error)
						{
							DTLogError(@"Error updating web credential: %@", [(__bridge NSError *)error localizedDescription]);
						}
					});
				}
			}
			
			[self _loginCompleteForUser:result];
		});
	}];
}

- (void)showSignUp:(id)sender
{
	_nameField.text = nil;
	_passwordField.text = nil;
	
	PLYSignUpViewController *signup = [[PLYSignUpViewController alloc] init];
	signup.productLayerServer = self.productLayerServer;
	signup.delegate = self;
	
	[self.navigationController pushViewController:signup animated:YES];
}

- (void)showLostPassword:(id)sender
{
	PLYLostPasswordViewController *lostPw = [[PLYLostPasswordViewController alloc] init];
	lostPw.productLayerServer = self.productLayerServer;
	lostPw.delegate = self;
	
	[self.navigationController pushViewController:lostPw animated:YES];
}

- (void)_signInFlowWithRequest:(NSURLRequest *)request
{
	PLYSocialAuthWebViewController *webVC = [[PLYSocialAuthWebViewController alloc] init];
	//	webVC.authorizationDelegate = self;
	
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
	
	// present sign in forms with same modal style as self
	nav.modalPresentationStyle = self.modalPresentationStyle;
	
	[self presentViewController:nav animated:YES completion:NULL];
	
	[webVC startAuthorizationFlowWithRequest:request completion:^(BOOL isAuthenticated, NSString *token)
	 {
		 [self dismissViewControllerAnimated:YES completion:^{
			 
			 if (isAuthenticated)
			 {
				 [self.productLayerServer loginWithToken:token completion:^(id result, NSError *error) {
					 
					 if (!result)
					 {
						 return;
					 }
					 
					 DTBlockPerformSyncIfOnMainThreadElseAsync(^{
						 [self _loginCompleteForUser:result];
					 });
				 }];
			 }
		 }];
	 }];
}

- (IBAction)signInWithTwitter:(id)sender
{
	NSURLRequest *request = [self.productLayerServer URLRequestForTwitterSignIn];
	[self _signInFlowWithRequest:request];
}

- (IBAction)signInWithFacebook:(id)sender
{
	NSURLRequest *request = [self.productLayerServer URLRequestForFacebookSignIn];
	[self _signInFlowWithRequest:request];
}

- (IBAction)dismissKeyboardTap:(id)sender
{
	[_nameField resignFirstResponder];
	[_passwordField resignFirstResponder];
}

#pragma mark - Form Validation

- (BOOL)_allFieldsValid
{
	for (PLYFormValidator *oneValidator in _validators)
	{
		// revalidate
		[oneValidator validate];

		if (!oneValidator.isValid)
		{
			return NO;
		}
	}
	
	return YES;
}

- (void)validityDidChange:(PLYFormValidator *)validator
{
	for (PLYFormValidator *oneValidator in _validators)
	{
		if (!oneValidator.isValid)
		{
			_rightButton.enabled = NO;
			return;
		}
	}
	
	_rightButton.enabled = YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _nameField)
	{
		[_passwordField becomeFirstResponder];
		return YES;
	}
	
	if ([self _allFieldsValid])
	{
		[self done:nil];
		return YES;
	}
	
	return NO;
}

#pragma mark - PLYLostPasswordViewControllerDelegate

- (void)lostPasswordViewController:(PLYLostPasswordViewController *)lostPasswordViewController didRequestNewPasswordForUser:(PLYUser *)user
{
	_nameField.text = user.nickname;
    
	[self.navigationController popToViewController:self animated:YES];
    
    NSString *title = PLYLocalizedStringFromTable(@"PLY_LOSTPW_SUCCESS_ALERT_TITLE", @"UI", @"Title for successful password reset");
				NSString *msg = PLYLocalizedStringFromTable(@"PLY_LOSTPW_SUCCESS_ALERT_MSG", @"UI", @"Message for successful password reset");
				
				UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
				
				UIAlertAction *okButton = [UIAlertAction actionWithTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
				
				[alert addAction:okButton];
    
    [self.navigationController presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - PLYSignUpViewControllerDelegate

- (void)signUpViewController:(PLYSignUpViewController *)lostPasswordViewController didSignUpNewUser:(PLYUser *)user
{
	_nameField.text = user.nickname;
	[self.navigationController popToViewController:self animated:YES];
}

@end