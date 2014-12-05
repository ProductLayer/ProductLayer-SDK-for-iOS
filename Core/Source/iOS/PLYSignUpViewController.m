//
//  PLYSignUpViewController.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/16/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYSignUpViewController.h"
#import "UIViewController+ProductLayer.h"

#import "ProductLayer.h"

#import "DTBlockFunctions.h"
#import "DTAlertView.h"

@interface PLYSignUpViewController () <PLYFormValidationDelegate, UITextFieldDelegate>

@end

@implementation PLYSignUpViewController
{
	NSArray *_validators;
	
	UIBarButtonItem *_leftButton;
	UIBarButtonItem *_rightButton;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UILabel *explainLabel = [[UILabel alloc] init];
	explainLabel.text = PLYLocalizedStringFromTable(@"PLY_SIGNUP_EXPLAIN", @"UI", @"Explanation to show on sign up dialog");
	explainLabel.translatesAutoresizingMaskIntoConstraints = NO;
	explainLabel.numberOfLines = 0;
	explainLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[explainLabel sizeToFit];
	[self.view addSubview:explainLabel];
	
	NSMutableArray *validators = [NSMutableArray array];
	
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
	
	PLYFormEmailValidator *emailValidator = [PLYFormEmailValidator validatorWithDelegate:self];
	[validators addObject:emailValidator];
	
	_emailField = [[PLYTextField alloc] initWithFrame:CGRectZero];
	_emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	_emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_emailField.spellCheckingType = UITextSpellCheckingTypeNo;
	_emailField.keyboardType = UIKeyboardTypeEmailAddress;
	_emailField.placeholder = PLYLocalizedStringFromTable(@"PLY_EMAIL_PLACEHOLDER", @"UI", @"Placeholder for email text field");
	_emailField.validator = emailValidator;
	_emailField.returnKeyType = UIReturnKeySend;
	_emailField.delegate = self;
	_emailField.enablesReturnKeyAutomatically = YES;
	[self.view addSubview:_emailField];
	
	_validators = [validators copy];
	
	
	id topGuide = [self topLayoutGuide];
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_nameField, _emailField, topGuide, explainLabel);
	NSArray *constraints1 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[explainLabel]-[_nameField]-[_emailField]"
														 options:0 metrics:nil views:viewsDictionary];
	NSArray *constraints2 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_nameField(300)]"
														 options:0 metrics:nil views:viewsDictionary];
	NSArray *constraints3 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_emailField(300)]"
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
	 [NSLayoutConstraint constraintWithItem:_emailField
											attribute:NSLayoutAttributeCenterX
											relatedBy:NSLayoutRelationEqual
												toItem:self.view
											attribute:NSLayoutAttributeCenterX
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
	
	[self.navigationController.view setTintColor:PLYBrandColor()];
	
	NSString *title = PLYLocalizedStringFromTable(@"PLY_SIGNUP_RIGHT_BUTTON_TITLE", @"UI", @"Text for done button in sign up dialog");
	_rightButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
	_rightButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = _rightButton;
}

- (BOOL)shouldAutorotate
{
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (self.navigationController.viewControllers[0] == self)
	{
		_leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
		self.navigationItem.leftBarButtonItem = _leftButton;
	}
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
	
	[self.productLayerServer createUserWithName:_nameField.text email:_emailField.text completion:^(id result, NSError *error) {
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			
			if (error)
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PLYLocalizedStringFromTable(@"PLY_SIGNUP_ERROR_ALERT", @"UI", @"Title of alert in signup dialog")
																				message:[error localizedDescription]
																			  delegate:nil
																  cancelButtonTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title")
																  otherButtonTitles:nil];
				alert.tintColor = [UIColor redColor];
				[alert show];

				// restore button
				self.navigationItem.rightBarButtonItem = _rightButton;

				return;
			}

			// set thumbs up
			UIBarButtonItem *check = [[UIBarButtonItem alloc] initWithTitle:@"👍" style:UIBarButtonItemStylePlain target:nil action:NULL];
			check.tintColor = self.navigationController.view.tintColor;
			self.navigationItem.rightBarButtonItem = check;
			
			NSString *title = PLYLocalizedStringFromTable(@"PLY_SIGNUP_SUCCESS_ALERT_TITLE", @"UI", @"Title for successful sign up");
			NSString *msg = PLYLocalizedStringFromTable(@"PLY_SIGNUP_SUCCESS_ALERT_MSG", @"UI", @"Message for successful sign up");
			DTAlertView *alert = [[DTAlertView alloc] initWithTitle:title
																			message:msg];
			
			[alert addButtonWithTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title")
									  block:^{
										  if ([_delegate respondsToSelector:@selector(signUpViewController:didSignUpNewUser:)])
										  {
											  [_delegate signUpViewController:self didSignUpNewUser:result];
										  }
									  }];
			
			[alert show];
		});
	}];
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
		[_emailField becomeFirstResponder];
		return NO;
	}
	
	if ([self _allFieldsValid])
	{
		[self done:nil];
	}
	
	return NO;
}

@end
