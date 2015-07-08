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
{
	NSString *_lastKeyboardLanguage;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self)
	 {
		 [self _commonSetup];
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self _commonSetup];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)becomeFirstResponder
{
	[self _updateUsedLanguage];
	
	return [super becomeFirstResponder];
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

#pragma mark - Helpers

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
	
	// keep track of the keyboard language
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputModeDidChange:) name:@"UITextInputCurrentInputModeDidChangeNotification" object:nil];
	
	// default language is current system language
	_lastKeyboardLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
	_usedInputLanguage = _lastKeyboardLanguage;
}

- (void)_updateUsedLanguage
{
	UITextInputMode *inputMode = [self textInputMode];
	NSString *lang = inputMode.primaryLanguage;
	
	if (!lang || [lang isEqualToString:@"dictation"] || [lang isEqualToString:@"mul"])
	{
		return;
	}
	
	NSRange range = [lang rangeOfString:@"-"];
	
	if (range.location != NSNotFound)
	{
		lang = [lang substringToIndex:range.location];
	}
	
	_lastKeyboardLanguage = lang;
}

#pragma mark - Actions

- (void)textChanged:(PLYTextField *)sender
{
	_usedInputLanguage = _lastKeyboardLanguage;
	
	[_validator validate];
}

#pragma mark - Notifications

- (void)inputModeDidChange:(NSNotification *)notification
{
	[self _updateUsedLanguage];
}


#pragma mark - Properties

- (void)setText:(NSString *)text
{
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
