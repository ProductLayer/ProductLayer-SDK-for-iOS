//
//  PLYLostPasswordViewController.m
//  PL
//
//  Created by Oliver Drobnik on 28/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYLostPasswordViewController.h"
#import "PLYFormEmailValidator.h"
#import "PLYTextField.h"
#import "PLYServer.h"

#import "DTBlockFunctions.h"
#import "DTAlertView.h"

@interface PLYLostPasswordViewController () <PLYFormValidationDelegate>

@end

@implementation PLYLostPasswordViewController
{
	NSArray *_validators;
	UIBarButtonItem *_rightButton;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UILabel *explainLabel = [[UILabel alloc] init];
	explainLabel.text = @"Enter your email address to have ProductLayer set a new random password and email it to you.";
	explainLabel.translatesAutoresizingMaskIntoConstraints = NO;
	explainLabel.numberOfLines = 0;
	explainLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[explainLabel sizeToFit];
	[self.view addSubview:explainLabel];
	
	NSMutableArray *validators = [NSMutableArray array];
	
	PLYFormEmailValidator *emailValidator = [PLYFormEmailValidator validatorWithDelegate:self];
	[validators addObject:emailValidator];
	
	_emailField = [[PLYTextField alloc] initWithFrame:CGRectZero];
	_emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	_emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_emailField.spellCheckingType = UITextSpellCheckingTypeNo;
	_emailField.keyboardType = UIKeyboardTypeEmailAddress;
	_emailField.placeholder = @"john@productlayer.com";
	_emailField.validator = emailValidator;
	_emailField.returnKeyType = UIReturnKeySend;
	_emailField.enablesReturnKeyAutomatically = YES;
	[self.view addSubview:_emailField];
	
	_validators = [validators copy];
	
	
	id topGuide = [self topLayoutGuide];
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_emailField, topGuide, explainLabel);
	NSArray *constraints1 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-[explainLabel]-[_emailField]"
														 options:0 metrics:nil views:viewsDictionary];
	NSArray *constraints3 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_emailField(300)]"
														 options:0 metrics:nil views:viewsDictionary];
	
	NSArray *constraints4 =
	[NSLayoutConstraint constraintsWithVisualFormat:@"H:[explainLabel(280)]"
														 options:0 metrics:nil views:viewsDictionary];
	
	[self.view addConstraints:constraints1];
	[self.view addConstraints:constraints3];
	[self.view addConstraints:constraints4];
	
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
	
	_rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
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

#pragma mark - Actions

- (void)done:(id)sender
{
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
	
	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activity startAnimating];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];

	[self.server requestNewPasswordForUserWithEmail:_emailField.text completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			if (error)
			{
				// restore right button
				self.navigationItem.rightBarButtonItem = _rightButton;
				
				NSString *msg = [error localizedDescription];
				
				if (error.code == 404)
				{
					msg = @"There is no user with this email address.";
				}

				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Password Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			}
			else
			{
				UIBarButtonItem *check = [[UIBarButtonItem alloc] initWithTitle:@"👍" style:UIBarButtonItemStylePlain target:nil action:NULL];
				check.tintColor = self.navigationController.view.tintColor;
				self.navigationItem.rightBarButtonItem = check;
				
				DTAlertView *alert = [[DTAlertView alloc] initWithTitle:@"New Password Send" message:@"A new password was send to you by email."];
				
				[alert addButtonWithTitle:@"Ok" block:^{
					if ([_delegate respondsToSelector:@selector(lostPasswordViewController:didRequestNewPasswordForUser:)])
					{
						[_delegate lostPasswordViewController:self didRequestNewPasswordForUser:result];
					}
				}];
				
				[alert show];
			}
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
