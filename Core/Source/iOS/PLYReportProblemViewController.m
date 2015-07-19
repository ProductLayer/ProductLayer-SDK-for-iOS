//
//  PLYReportProblemViewController.m
//  ProdlyApp
//
//  Created by Oliver Drobnik on 23.01.15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYReportProblemViewController.h"
#import "PLYTextView.h"

#import "ProductLayerUI.h"
#import "PLYProblemReport.h"

#import "DTBlockFunctions.h"

@interface PLYReportProblemViewController () <UITextViewDelegate>

@end

@implementation PLYReportProblemViewController
{
	// Nav Bar
	UIBarButtonItem *_saveButtonItem;
	UIBarButtonItem *_cancelButtonItem;
	
	// UI
	UIView *_frameView;
	PLYTextView *_textView;
	
	NSLayoutConstraint *_bottomMarginConstraint;
}

- (void)loadView
{
	_saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(sendReport:)];
	self.navigationItem.rightBarButtonItem = _saveButtonItem;
	
	_cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = _cancelButtonItem;
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
	view.backgroundColor = [UIColor whiteColor];
	
	_frameView = [[UIView alloc] initWithFrame:CGRectZero];
	_frameView.translatesAutoresizingMaskIntoConstraints = NO;
	_frameView.layer.borderColor = PLYBrandColor().CGColor;
	_frameView.layer.borderWidth = 1;
	_frameView.layer.cornerRadius = 10;
	_frameView.clipsToBounds = YES;
	[view addSubview:_frameView];
	
	_textView = [[PLYTextView alloc] initWithFrame:CGRectZero];
	_textView.translatesAutoresizingMaskIntoConstraints = NO;
	_textView.delegate = self;
	_textView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 0, 0);
	_textView.keyboardType = UIKeyboardTypeTwitter;
	[_frameView addSubview:_textView];
	
	[_frameView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeLeft
																			 relatedBy:NSLayoutRelationEqual
																				 toItem:_frameView
																			 attribute:NSLayoutAttributeLeft
																			multiplier:1.0
																			  constant:5]];
	
	[_frameView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeRight
																			 relatedBy:NSLayoutRelationEqual
																				 toItem:_frameView
																			 attribute:NSLayoutAttributeRight
																			multiplier:1.0
																			  constant:-5]];
	
	[_frameView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeTop
																			 relatedBy:NSLayoutRelationEqual
																				 toItem:_frameView
																			 attribute:NSLayoutAttributeTop
																			multiplier:1.0
																			  constant:0]];
	
	[_frameView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeBottom
																			 relatedBy:NSLayoutRelationEqual
																				 toItem:_frameView
																			 attribute:NSLayoutAttributeBottom
																			multiplier:1.0
																			  constant:0]];
	
	self.view = view;
	
	[self _updateLabelFonts];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:_frameView attribute:NSLayoutAttributeTop
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:self.topLayoutGuide
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:10]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:_frameView attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:view
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0
																	  constant:10]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_frameView attribute:NSLayoutAttributeRight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:view
																	 attribute:NSLayoutAttributeRight
																	multiplier:1.0
																	  constant:-10]];
	
	
	_bottomMarginConstraint = [NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide
																			 attribute:NSLayoutAttributeTop
																			 relatedBy:NSLayoutRelationEqual
																				 toItem:_frameView
																			 attribute:NSLayoutAttributeBottom
																			multiplier:1.0
																			  constant:10];
	_bottomMarginConstraint.priority = UILayoutPriorityDefaultHigh;
	[view addConstraint:_bottomMarginConstraint];
	
	self.navigationItem.title = PLYLocalizedStringFromTable(@"REPORT_PROBLEM_TITLE", @"UI", @"Title of report problem composer");
	
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelItem;
	
	_saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(sendReport:)];
	self.navigationItem.rightBarButtonItem = _saveButtonItem;
	
	[self _updateSaveButtonState];
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// observe the font size
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(_didChangePreferredContentSize:)
																name:UIContentSizeCategoryDidChangeNotification
															 object:nil];
}


- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSString *format = PLYLocalizedStringFromTable(@"REPORT_PROBLEM_TITLE", @"UI", @"Title of report problem composer");
	NSString *itemName;
	
	if ([_problematicEntity isKindOfClass:[PLYUser class]] || [_problematicEntity isKindOfClass:[PLYUserAvatar class]])
	{
		itemName = PLYLocalizedStringFromTable(@"REPORT_TYPE_USER", @"UI", @"A user");
	}
	else if ([_problematicEntity isKindOfClass:[PLYImage class]])
	{
		itemName = PLYLocalizedStringFromTable(@"REPORT_TYPE_IMAGE", @"UI", @"An image");
	}
	else if ([_problematicEntity isKindOfClass:[PLYProduct class]])
	{
		itemName = PLYLocalizedStringFromTable(@"REPORT_TYPE_PRODUCT", @"UI", @"A product");
	}
	else if ([_problematicEntity isKindOfClass:[PLYOpine class]])
	{
		itemName = PLYLocalizedStringFromTable(@"REPORT_TYPE_OPINE", @"UI", @"An opine");
	}
	else
	{
		NSAssert(NO, @"Can't report issue on such an entity");
	}
	
	self.navigationItem.title = [NSString stringWithFormat:format, itemName];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[_textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[_textView resignFirstResponder];
}

#pragma mark - Helpers

- (void)_updateLabelFonts
{
	_textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)_updateSaveButtonState
{
	_saveButtonItem.enabled = [_textView.text length]>0;
}

- (void)_beginSaving
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activity startAnimating];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
	});
}

- (void)_endSaving
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		self.navigationItem.rightBarButtonItem = _saveButtonItem;
	});
}

- (void)_savingComplete
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		UIBarButtonItem *check = [[UIBarButtonItem alloc] initWithTitle:@"👍" style:UIBarButtonItemStylePlain target:nil action:NULL];
		check.tintColor = self.navigationController.view.tintColor;
		self.navigationItem.rightBarButtonItem = check;
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self dismissViewControllerAnimated:YES completion:NULL];
		});
	});
}

- (void)showErrorPanelWithTitle:(NSString *)title error:(NSError *)error
{
	if (error)
	{
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:PLYLocalizedStringFromTable(@"PLY_REPORT_FAILED_TITLE", @"UI", @"Alert title when creating of problem report fails")
																			message:[error localizedDescription]
																		  delegate:nil
															  cancelButtonTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title")
															  otherButtonTitles:nil];
			alert.tintColor = [UIColor redColor];
			[alert show];
		});

		
		return;
	}
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
	[self _updateSaveButtonState];
}

#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
	// keyboard frame is in window coordinates
	NSDictionary *userInfo = [notification userInfo];
	CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
 
	// convert own frame to window coordinates, frame is in superview's coordinates
	CGRect ownFrame = [self.view.window convertRect:self.view.frame fromView:self.view.superview];
 
	// calculate the area of own frame that is covered by keyboard
	CGRect coveredFrame = CGRectIntersection(ownFrame, keyboardFrame);
 
	// now this might be rotated, so convert it back
	coveredFrame = [self.view.window convertRect:coveredFrame toView:self.view.superview];
 
	// set inset to make up for covered height at bottom
	_bottomMarginConstraint.constant = coveredFrame.size.height + 10;
	
	NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	NSUInteger options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
	
	[UIView animateWithDuration:duration
								 delay:0
							  options:options | UIViewAnimationOptionBeginFromCurrentState
						  animations:^{
							  [self.view layoutIfNeeded];
						  } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	// set inset to make up for no longer covered array at bottom
	_bottomMarginConstraint.constant = 10;
	
	NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	NSUInteger options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
	
	[UIView animateWithDuration:duration
								 delay:0
							  options:options | UIViewAnimationOptionBeginFromCurrentState
						  animations:^{
							  [self.view layoutIfNeeded];
						  } completion:NULL];
}

- (void)_didChangePreferredContentSize:(NSNotification *)notification
{
	[self _updateLabelFonts];
}

#pragma mark - Actions

- (IBAction)sendReport:(id)sender
{
	
	[self _beginSaving];
	
	PLYProblemReport *report = [PLYProblemReport new];
	report.text = _textView.text;
	report.entity = _problematicEntity;

	[self.productLayerServer createProblemReport:report completion:^(id result, NSError *error) {
		
		if (result)
		{
			[self _savingComplete];
		}
		else
		{
			[self showErrorPanelWithTitle:@"Error sending problem report" error:error];
			[self _endSaving];
		}
	}];
}

/**
 Action to cancel the report composition
 */
- (IBAction)cancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
