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

- (void)_commonSetup
{
	// keep track of the keyboard language
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputModeDidChange:) name:@"UITextInputCurrentInputModeDidChangeNotification" object:nil];
}

- (void)insertText:(NSString *)text
{
	[super insertText:text];
	
	_usedInputLanguage = _lastKeyboardLanguage;
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
	[super replaceRange:range withText:text];
	
	_usedInputLanguage = _lastKeyboardLanguage;
}

#pragma mark - Notifications

- (void)inputModeDidChange:(NSNotification *)notification
{
	UITextInputMode *inputMode = [self textInputMode];
	NSString *lang = inputMode.primaryLanguage;
	
	if (!lang || [lang isEqualToString:@"dictation"])
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

@end
