//
//  PLYTextView.m
//  PL
//
//  Created by Oliver Drobnik on 28/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYTextView.h"
#import "PLYFunctions.h"

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

- (NSString *)replacementTextForURL:(NSURL *)URL
{
    if (!URL)
    {
        return nil;
    }
    
    if (![URL.host isEqualToString:@"prod.ly"])
    {
        return nil;
    }
    
    NSMutableArray *pathComponents = [URL.pathComponents mutableCopy];
    
    if ([pathComponents.firstObject isEqualToString:@"/"])
    {
        [pathComponents removeObjectAtIndex:0];
    }
    
    if (![pathComponents.firstObject isEqualToString:@"product"])
    {
        return nil;
    }
    
    [pathComponents removeObjectAtIndex:0];
    
    NSString *GTIN = pathComponents.firstObject;
    
    if (!PLYIsValidGTIN(GTIN))
    {
        return nil;
    }
    
    return [@"#" stringByAppendingString:GTIN];
}


- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
	// update language first, other observers might need it
	_usedInputLanguage = _lastKeyboardLanguage;
    
	[super replaceRange:range withText:text];
}

- (void)paste:(id)sender
{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    
    NSURL *URL = pboard.URL;
    
    if (URL)
    {
        NSString *replacement = [self replacementTextForURL:URL];
        
        if (replacement)
        {
            [self replaceRange:self.selectedTextRange withText:replacement];
            return;
        }
    }
    
    [super paste:sender];
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
