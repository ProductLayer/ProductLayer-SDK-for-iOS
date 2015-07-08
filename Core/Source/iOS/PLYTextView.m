//
//  PLYTextView.m
//  PL
//
//  Created by Oliver Drobnik on 28/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYTextView.h"

@implementation PLYTextView
{
	NSString *_lastKeyboardLanguage;
}

- (instancetype)initWithFrame:(CGRect)frame
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

- (void)insertText:(NSString *)text
{
	// update language first, other observers might need it
	_usedInputLanguage = _lastKeyboardLanguage;
	
	[super insertText:text];
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
	// update language first, other observers might need it
	_usedInputLanguage = _lastKeyboardLanguage;
	
	[super replaceRange:range withText:text];
}

- (BOOL)becomeFirstResponder
{
	[self _updateUsedLanguage];
	
	return [super becomeFirstResponder];
}

#pragma mark - Helpers

- (void)_commonSetup
{
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

#pragma mark - Notifications

- (void)inputModeDidChange:(NSNotification *)notification
{
	[self _updateUsedLanguage];
}

@end
