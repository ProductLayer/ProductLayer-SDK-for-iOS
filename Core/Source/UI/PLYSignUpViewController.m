//
//  PLYSignUpViewController.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/16/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYServer.h"
#import "PLYSignUpViewController.h"
#import "PLYTextField.h"
#import "PLYFormValidator.h"
#import "PLYUserNameValidator.h"
#import "PLYFormEmailValidator.h"

#import "DTBlockFunctions.h"

@interface PLYSignUpViewController () <PLYFormValidationDelegate>

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
	
	UILabel *explainLabel = [[UILabel alloc] init];
	explainLabel.text = @"Pick a nickname and enter your email address so that we can send you the initial password.";
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
	_nameField.placeholder = @"John Appleseed";
	_nameField.validator = nameValidator;
	[self.view addSubview:_nameField];
	
	PLYFormEmailValidator *emailValidator = [PLYFormEmailValidator validatorWithDelegate:self];
	[validators addObject:emailValidator];
	
	_emailField = [[PLYTextField alloc] initWithFrame:CGRectZero];
	_emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	_emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_emailField.spellCheckingType = UITextSpellCheckingTypeNo;
	_emailField.keyboardType = UIKeyboardTypeEmailAddress;
	_emailField.placeholder = @"john@productlayer.com";
	_emailField.validator = emailValidator;
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
	
	UIColor *plGreen = [UIColor colorWithRed:110.0/256.0 green:190.0/256.0 blue:68.0/256.0 alpha:1];
	[self.navigationController.view setTintColor:plGreen];
	
	_rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
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
	
	[self.server createUserWithName:_nameField.text email:_emailField.text completion:^(id result, NSError *error) {
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			self.navigationItem.rightBarButtonItem = _rightButton;
			
			if (error)
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Failed"
																				message:[error localizedDescription]
																			  delegate:nil
																  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				alert.tintColor = [UIColor redColor];
				[alert show];
				
				return;
			}
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Complete"
																			message:@"Please check your email inbox. You will receive an initial password which you should change. Then you may login in with your user name and password."
																		  delegate:nil
															  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			
			[self dismissViewControllerAnimated:YES completion:NULL];
		});
	}];
}

#pragma mark - Form Validation

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

@end
