//
//  PLYLostPasswordViewController.m
//  PL
//
//  Created by Oliver Drobnik on 28/07/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYLostPasswordViewController.h"
#import "UIViewController+ProductLayer.h"

#import "ProductLayerUI.h"

#import "DTBlockFunctions.h"
#import "DTAlertView.h"

@interface PLYLostPasswordViewController () <PLYFormValidationDelegate, UITextFieldDelegate>

@end

@implementation PLYLostPasswordViewController
{
	NSArray *_validators;
	UIBarButtonItem *_rightButton;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UILabel *explainLabel = [[UILabel alloc] init];
	explainLabel.text = PLYLocalizedStringFromTable(@"PLY_LOSTPW_EXPLAIN", @"UI", @"Explanation to show on lost password dialog");
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
	_emailField.placeholder = PLYLocalizedStringFromTable(@"PLY_EMAIL_PLACEHOLDER", @"UI", @"Placeholder for email text field");
	_emailField.validator = emailValidator;
	_emailField.returnKeyType = UIReturnKeySend;
    _emailField.delegate = self;
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
	
	[self.navigationController.view setTintColor:PLYBrandColor()];
	
	NSString *title = PLYLocalizedStringFromTable(@"PLY_LOSTPW_RIGHT_BUTTON_TITLE", @"UI", @"Text for done button in lost password dialog");
	_rightButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
	_rightButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = _rightButton;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (PLY_SUPPORTED_INTERFACE_ORIENTATIONS_RETURN_TYPE)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_emailField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // dismiss keyboard
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

#pragma mark - Actions

- (void)done:(id)sender
{
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
	
	UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activity startAnimating];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];

	[self.productLayerServer requestNewPasswordForUserWithEmail:_emailField.text completion:^(id result, NSError *error) {
		
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			if (error)
			{
				// restore right button
				self.navigationItem.rightBarButtonItem = _rightButton;
				
				NSString *msg = [error localizedDescription];
				
				if (error.code == 404)
				{
					msg = PLYLocalizedStringFromTable(@"PLY_LOSTPW_NO_USER", @"UI", @"Alert when user is not found");
				}

				NSString *title = PLYLocalizedStringFromTable(@"PLY_LOSTPW_ERROR_ALERT", @"UI", @"Title of alert in lost password dialog");
				NSString *cancelTitle = PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title");
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil];
				[alert show];
			}
			else
			{
				UIBarButtonItem *check = [[UIBarButtonItem alloc] initWithTitle:@"👍" style:UIBarButtonItemStylePlain target:nil action:NULL];
				check.tintColor = self.navigationController.view.tintColor;
				self.navigationItem.rightBarButtonItem = check;
				
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([_delegate respondsToSelector:@selector(lostPasswordViewController:didRequestNewPasswordForUser:)])
                    {
                        [_delegate lostPasswordViewController:self didRequestNewPasswordForUser:result];
                    }
                });
			}
		});
	}];
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
	if ([self _allFieldsValid])
	{
		[self done:nil];
		
		return YES;
	}
	
	return NO;
}

@end
