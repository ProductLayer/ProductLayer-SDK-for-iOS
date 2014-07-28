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

#import "PLYServer.h"
#import "PLYUser.h"
#import "PLYTextField.h"
#import "PLYFormValidator.h"
#import "PLYUserNameValidator.h"
#import "PLYFormEmailValidator.h"

#import "DTBlockFunctions.h"

@interface PLYLoginViewController () <PLYFormValidationDelegate, PLYLostPasswordViewControllerDelegate, PLYSignUpViewControllerDelegate, UITextFieldDelegate>

@end

@implementation PLYLoginViewController
{
	NSArray *_validators;
	
	UIBarButtonItem *_leftButton;
	UIBarButtonItem *_rightButton;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIColor *plGreen = [UIColor colorWithRed:110.0/256.0 green:190.0/256.0 blue:68.0/256.0 alpha:1];

	
	NSMutableArray *validators = [NSMutableArray array];
	
	UILabel *explainLabel = [[UILabel alloc] init];
	explainLabel.text = @"Login to ProductLayer to see your friends timeline and post your own opines.";
	explainLabel.translatesAutoresizingMaskIntoConstraints = NO;
	explainLabel.numberOfLines = 0;
	explainLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[explainLabel sizeToFit];
	[self.view addSubview:explainLabel];
	
	PLYUserNameValidator *nameValidator = [PLYUserNameValidator validatorWithDelegate:self];
	[validators addObject:nameValidator];
	
	_nameField = [[PLYTextField alloc] initWithFrame:CGRectZero];
	_nameField.autocorrectionType = UITextAutocorrectionTypeNo;
	_nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_nameField.spellCheckingType = UITextSpellCheckingTypeNo;
	_nameField.placeholder = @"John Appleseed";
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
	_passwordField.placeholder = @"secret";
	_passwordField.validator = passwordValidator;
	_passwordField.returnKeyType = UIReturnKeySend;
	_passwordField.delegate = self;
	_passwordField.enablesReturnKeyAutomatically = YES;
	[self.view addSubview:_passwordField];
	
	UIButton *lostPwButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[lostPwButton setTitle:@"Lost Password ..." forState:UIControlStateNormal];
	lostPwButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[lostPwButton addTarget:self action:@selector(showLostPassword:) forControlEvents:UIControlEventTouchUpInside];
	lostPwButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:lostPwButton];
	
	UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[signupButton setTitle:@"Create New Account ..." forState:UIControlStateNormal];
	signupButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[signupButton addTarget:self action:@selector(showSignUp:) forControlEvents:UIControlEventTouchUpInside];
	signupButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:signupButton];
	
	_validators = [validators copy];
	
	
	id topGuide = [self topLayoutGuide];
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_nameField, _passwordField, topGuide, lostPwButton, signupButton, explainLabel);
	NSArray *constraints1 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[explainLabel]-[_nameField]-[_passwordField]-[lostPwButton]-[signupButton]"
														 options:0 metrics:nil views:viewsDictionary];
	NSArray *constraints2 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_nameField(300)]"
														 options:0 metrics:nil views:viewsDictionary];
	NSArray *constraints3 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_passwordField(300)]"
														 options:0 metrics:nil views:viewsDictionary];
	
	NSArray *constraints4 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[explainLabel(280)]"
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
	 [NSLayoutConstraint constraintWithItem:explainLabel
											attribute:NSLayoutAttributeCenterX
											relatedBy:NSLayoutRelationEqual
												toItem:self.view
											attribute:NSLayoutAttributeCenterX
										  multiplier:1
											 constant:0]];
	
	[self.navigationController.view setTintColor:plGreen];
	
	_leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = _leftButton;
	
	_rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
	_rightButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = _rightButton;
	
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered target:nil action:NULL];
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationPortrait;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)done:(id)sender
{
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];

	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activity startAnimating];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
	
	[self.server loginWithUser:_nameField.text password:_passwordField.text completion:^(id result, NSError *error) {
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			// restore right button
			self.navigationItem.rightBarButtonItem = _rightButton;
			
			if (error)
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed"
																				message:[error localizedDescription]
																			  delegate:nil
																  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				alert.tintColor = [UIColor redColor];
				[alert show];
				
				return;
			}
			
			UIBarButtonItem *check = [[UIBarButtonItem alloc] initWithTitle:@"👍" style:UIBarButtonItemStylePlain target:nil action:NULL];
			check.tintColor = self.navigationController.view.tintColor;
			self.navigationItem.rightBarButtonItem = check;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self dismissViewControllerAnimated:YES completion:NULL];
			});
		});
	}];
}

- (void)showSignUp:(id)sender
{
	_nameField.text = nil;
	_passwordField.text = nil;
	
	PLYSignUpViewController *signup = [[PLYSignUpViewController alloc] init];
	signup.server = self.server;
	signup.delegate = self;
	
	[self.navigationController pushViewController:signup animated:YES];
}

- (void)showLostPassword:(id)sender
{
	PLYLostPasswordViewController *lostPw = [[PLYLostPasswordViewController alloc] init];
	lostPw.server = self.server;
	lostPw.delegate = self;
	
	[self.navigationController pushViewController:lostPw animated:YES];
}

#pragma mark - Form Validation

- (BOOL)_allFieldsValid
{
	for (PLYFormValidator *oneValidator in _validators)
	{
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
		return NO;
	}
	
	if ([self _allFieldsValid])
	{
		[self done:nil];
	}
	
	return NO;
}

#pragma mark - PLYLostPasswordViewControllerDelegate

- (void)lostPasswordViewController:(PLYLostPasswordViewController *)lostPasswordViewController didRequestNewPasswordForUser:(PLYUser *)user
{
	_nameField.text = user.nickname;
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark - PLYSignUpViewControllerDelegate

- (void)signUpViewController:(PLYSignUpViewController *)lostPasswordViewController didSignUpNewUser:(PLYUser *)user
{
	_nameField.text = user.nickname;
	[self.navigationController popToViewController:self animated:YES];
}

@end