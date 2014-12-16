//
//  DTOpineComposeViewController.m
//  HungryScanner
//
//  Created by Oliver Drobnik on 23/10/14.
//  Copyright (c) 2014 Product Layer. All rights reserved.
//

#import "PLYOpineComposeViewController.h"
#import "UIViewController+ProductLayer.h"

#import "ProductLayer.h"

@interface PLYOpineComposeViewController () <UITextViewDelegate>

@end

@implementation PLYOpineComposeViewController
{
	PLYTextView *_textView;
	
	UIBarButtonItem *_saveButtonItem;
	UIBarButtonItem *_cancelButtonItem;
	
	NSString *_text;
	NSString *_language;
	
	UIButton *_twitterButton;
	UIButton *_facebookButton;
	
	UILabel *_characterRemainingLabel;
	
	UIEdgeInsets _insets;
	
	BOOL _postToTwitter;
	BOOL _postToFacebook;
}

- (instancetype)initWithOpine:(PLYOpine *)opine
{
	self = [super init];
	
	if (self)
	{
		_text = opine.text;
		_language = opine.language;
		
		_postToTwitter = opine.shareOnTwitter;
		_postToFacebook = opine.shareOnFacebook;
	}
	
	return self;
}

- (void)dealloc
{
	[self.productLayerServer removeObserver:self forKeyPath:@"loggedInUser"];
	[[NSNotificationCenter  defaultCenter] removeObserver:self];
}

- (void)_updateSocialButtons
{
	if ([self.productLayerServer.loggedInUser.socialConnections[@"twitter"] boolValue])
	{
		_twitterButton.enabled = YES;
	}
	else
	{
		_postToTwitter = NO;
		_twitterButton.enabled = NO;
	}
	
	if ([self.productLayerServer.loggedInUser.socialConnections[@"facebook"] boolValue])
	{
		_facebookButton.enabled = YES;
	}
	else
	{
		_postToFacebook = NO;
		_facebookButton.enabled = NO;
	}

	
	if (_postToFacebook)
	{
		_facebookButton.tintColor = PLYBrandColor();
	}
	else
	{
		_facebookButton.tintColor = [UIColor grayColor];
	}
	
	if (_postToTwitter)
	{
		_twitterButton.tintColor = PLYBrandColor();
	}
	else
	{
		_twitterButton.tintColor = [UIColor grayColor];
	}
}

- (void)loadView
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	view.backgroundColor = [UIColor whiteColor];
	
	_textView = [[PLYTextView alloc] initWithFrame:CGRectInset(view.bounds, 20, 20)];
	_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_textView.delegate = self;
	_textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	_textView.layer.borderColor = PLYBrandColor().CGColor;
	_textView.layer.borderWidth = 1;
	_textView.layer.cornerRadius = 10;
	_textView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
	_textView.keyboardType = UIKeyboardTypeTwitter;
	_textView.textContainerInset = UIEdgeInsetsMake(10, 5, 30, 5);
	
	[view addSubview:_textView];

	NSString *twitterPath = [PLYResourceBundle() pathForResource:@"twitter" ofType:@"png"];
	UIImage *twitterIcon = [[UIImage imageWithContentsOfFile:twitterPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	_twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_twitterButton.frame = CGRectMake(0, 100, 50, 50);
	[_twitterButton setImage:twitterIcon forState:UIControlStateNormal];
	[_twitterButton addTarget:self action:@selector(_handleTwitter:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:_twitterButton];
	
	NSString *facebookPath = [PLYResourceBundle() pathForResource:@"facebook" ofType:@"png"];
	UIImage *facebookIcon = [[UIImage imageWithContentsOfFile:facebookPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	_facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_facebookButton.frame = CGRectMake(100, 100, 50, 50);
	[_facebookButton setImage:facebookIcon forState:UIControlStateNormal];
	[_facebookButton addTarget:self action:@selector(_handleFacebook:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:_facebookButton];
	
	_characterRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
	_characterRemainingLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[view addSubview:_characterRemainingLabel];
	
	[self _updateSocialButtons];
	
	self.view = view;
	
	self.navigationItem.title = @"Your Opinion";
	
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelItem;
	
	_saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = _saveButtonItem;
	
	// default language is current system language
	if (!_language)
	{
		_language = [[NSLocale preferredLanguages] objectAtIndex:0];
	}
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	_insets = UIEdgeInsetsZero;
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(keyboardWillShow:)
						name:UIKeyboardWillShowNotification object:nil];
	[center addObserver:self selector:@selector(keyboardWillHide:)
						name:UIKeyboardWillHideNotification object:nil];
	
	// observe the logged in user
	[self.productLayerServer addObserver:self forKeyPath:@"loggedInUser" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	id<UILayoutSupport>top = [self topLayoutGuide];
	id<UILayoutSupport>bottom = [self bottomLayoutGuide];
	
	_textView.frame = CGRectMake(10+_insets.left, [top length]+10+_insets.top, self.view.bounds.size.width-20-_insets.left - _insets.right, self.view.bounds.size.height - [top length] - [bottom length] - 20 - _insets.bottom - 40);
	_facebookButton.frame = CGRectMake( CGRectGetMaxX(_textView.frame) - 50, CGRectGetMaxY(_textView.frame), 50, 50);
	_twitterButton.frame = CGRectMake( CGRectGetMaxX(_textView.frame) - 100, CGRectGetMaxY(_textView.frame), 50, 50);
	
	_characterRemainingLabel.frame = CGRectMake(CGRectGetMinX(_textView.frame)+10, CGRectGetMaxY(_textView.frame)-30, 50, 30);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_textView.text = _text;
	[self _updateButtonState];
	[self _updateCharacterCount];
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

- (void)_updateButtonState
{
	_saveButtonItem.enabled = [_textView.text length]>0;
}

- (void)_updateCharacterCount
{
	NSString *trimmedString = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSInteger remainingChars = 140 - [trimmedString length];
	
	if (_postToTwitter)
	{
		remainingChars -= 24;
	}
	
	if (remainingChars>=0)
	{
		_characterRemainingLabel.textColor = [UIColor lightGrayColor];
		_saveButtonItem.enabled = YES;
	}
	else
	{
		_characterRemainingLabel.textColor = [UIColor redColor];
		_saveButtonItem.enabled = NO;
	}
	
	_characterRemainingLabel.text = [NSString stringWithFormat:@"%ld", remainingChars];
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
	if ([_delegate respondsToSelector:@selector(opineComposeViewControllerDidCancel:)])
	{
		[_delegate opineComposeViewControllerDidCancel:self];
	}
	
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)save:(id)sender
{
	PLYOpine *opine = nil;
 
	// return nil if there is no text
	if ([_textView.text length])
	{
		opine = [[PLYOpine alloc] init];
		opine.text = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		opine.language = _language;
		opine.shareOnFacebook = _postToFacebook;
		opine.shareOnTwitter = _postToTwitter;
	}
	
	if ([_delegate respondsToSelector:@selector(opineComposeViewController:didFinishWithOpine:)])
	{
		[_delegate opineComposeViewController:self didFinishWithOpine:opine];
	}
	
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)_handleTwitter:(id)sender
{
	_postToTwitter = !_postToTwitter;
	[self _updateSocialButtons];
	[self _updateCharacterCount];
}

- (void)_handleFacebook:(id)sender
{
	_postToFacebook = !_postToFacebook;
	[self _updateSocialButtons];
	[self _updateCharacterCount];
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
 
	// set inset to make up for covered array at bottom
	_insets = UIEdgeInsetsMake(0, 0, coveredFrame.size.height, 0);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	[UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	// work
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
	
	[UIView commitAnimations];
	
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	// set inset to make up for no longer covered array at bottom
	_insets = UIEdgeInsetsMake(0, 0, 0, 0);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
	[UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	// work
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
	
	[UIView commitAnimations];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self _updateSocialButtons];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
	[self _updateButtonState];
	[self _updateCharacterCount];

	_language = _textView.usedInputLanguage;
}

#pragma mark - Public Interface

- (NSString *)opineText
{
	return _textView.text;
}

- (void)setOpineText:(NSString *)opineText
{
	if (!self.isViewLoaded)
	{
		[self loadView];
	}
	
	_textView.text = opineText;
}

- (void)setOpine:(PLYOpine *)opine
{
	_text = opine.text;
	_language = opine.language;
	
	_postToTwitter = opine.shareOnTwitter;
	_postToFacebook = opine.shareOnFacebook;
}

@end
