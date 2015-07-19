//
//  PLYGuidedInputViewController.m
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYGuidedInputViewController.h"
#import "ProductLayerUI.h"

@interface PLYGuidedInputViewController () <PLYFormValidationDelegate>
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet PLYTextField *textField;
@end

@implementation PLYGuidedInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	_textLabel.text = _label;
	_textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	
	_textField.text = _text;
	_textField.placeholder = _placeholder;
	_textField.validator = [PLYContentsDidChangeValidator validatorWithDelegate:self originalContents:_text];
	
	[_textField.validator validate];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[_textField resignFirstResponder];
}

// load view from the PL resource bundle
- (void)loadView
{
	NSBundle *resources = PLYResourceBundle();
	UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:resources];
	[nib instantiateWithOwner:self options:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(PLYTextField *)textField
{
	if (textField.validator.isValid)
	{
		[self save:nil];
	}
	else
	{
		[self cancel:nil];
	}
	
	return YES;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
	if ([_delegate respondsToSelector:@selector(guidedInputViewControllerDidCancel:)])
	{
		[_delegate guidedInputViewControllerDidCancel:self];
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (IBAction)save:(id)sender
{
	_text = _textField.text;
	_language = _textField.usedInputLanguage;
	
	if ([_delegate respondsToSelector:@selector(guidedInputViewControllerDidSave:)])
	{
		[_delegate guidedInputViewControllerDidSave:self];
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}
	 
#pragma mark - Form Validation

- (void)validityDidChange:(PLYFormValidator *)validator
{
	self.navigationItem.rightBarButtonItem.enabled = [validator isValid];
}

@end
