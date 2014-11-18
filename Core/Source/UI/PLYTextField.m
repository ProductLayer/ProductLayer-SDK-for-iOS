//
//  PLYTextField.m
//  Opinator
//
//  Created by Oliver Drobnik on 6/16/14.
//  Copyright (c) 2014 ProductLayer. All rights reserved.
//

#import "PLYTextField.h"
#import "PLYFormValidator.h"

@implementation PLYTextField


- (void)_commonSetup
{
	// rounded green border done with layer border instead of build in
	CALayer *layer = self.layer;
	layer.borderWidth = 1;
	layer.cornerRadius = 7;
	self.borderStyle = UITextBorderStyleNone;
	
	self.autocorrectionType = UITextAutocorrectionTypeNo;
	self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody]; //[UIFont fontWithName:@"HelveticaNeue" size:22.0f];
	
	self.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		 [self _commonSetup];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self _commonSetup];
}

- (void)tintColorDidChange
{
	[super tintColorDidChange];
	self.textColor = self.tintColor;
	self.layer.borderColor = self.tintColor.CGColor;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
	return CGRectInset(bounds, 7, 7);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	return [self textRectForBounds:bounds];
}

#pragma mark - Actions

- (void)textChanged:(PLYTextField *)sender
{
	[_validator validate];
}


#pragma mark - Properties

- (void)setText:(NSString *)text{
    [super setText:text];
    
    [_validator validate];
}

- (void)setValidator:(PLYFormValidator *)validator
{
	if (_validator != validator)
	{
		_validator = validator;
		
		// set week back reference
		_validator.control = self;
	
		[_validator validate];
	}
}

@end
