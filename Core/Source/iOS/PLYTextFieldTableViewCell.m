//
//  PLYTextFieldTableViewCell.m
//  ProdlyApp
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYTextFieldTableViewCell.h"

#import "PLYTextField.h"

@implementation PLYTextFieldTableViewCell
{
	PLYTextField *_textField;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect frame = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(0, 9, 0, 0));
	self.textField.frame = frame;
}

- (PLYTextField *)textField
{
	if (!_textField)
	{
		_textField = [[PLYTextField alloc] initWithFrame:CGRectZero];
		[self.contentView addSubview:_textField];
		
		_textField.layer.borderWidth = 0;
		
		// handle tap outside of text field
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
		[self.contentView addGestureRecognizer:tap];
	}
	
	return _textField;
}

#pragma mark - Actions

- (void)_handleTap:(UITapGestureRecognizer *)tap
{
	[_textField becomeFirstResponder];
}

@end
