//
//  PLYGuidedInputViewController.m
//  PL
//
//  Created by Oliver Drobnik on 18/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYGuidedInputViewController.h"
#import "ProductLayer.h"

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// load view from the PL resource bundle
- (void)loadView
{
	NSBundle *resources = PLYResourceBundle();
	UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:resources];
	[nib instantiateWithOwner:self options:nil];
}

- (IBAction)cancel:(id)sender {
	[self performSegueWithIdentifier:@"unwind" sender:sender];
}

- (IBAction)save:(id)sender {
	_text = _textField.text;
	[self performSegueWithIdentifier:@"unwind" sender:sender];
}

#pragma mark - Form Validation

- (void)validityDidChange:(PLYFormValidator *)validator
{
	self.navigationItem.rightBarButtonItem.enabled = [validator isValid];
}

@end
