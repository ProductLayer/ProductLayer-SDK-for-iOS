//
//  DTOpineComposeViewController.m
//  HungryScanner
//
//  Created by Oliver Drobnik on 23/10/14.
//  Copyright (c) 2014 Product Layer. All rights reserved.
//

#import "PLYOpineComposeViewController.h"
#import "UIViewController+ProductLayer.h"
#import <CoreLocation/CoreLocation.h>

#import "ProductLayer.h"
#import "DTBlockFunctions.h"
#import "DTLog.h"

@interface PLYOpineComposeViewController () <UITextViewDelegate, CLLocationManagerDelegate>

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
	UIButton *_locationButton;
	UILabel *_addressLabel;
	UILabel *_characterRemainingLabel;
	
	UIEdgeInsets _insets;
	
	BOOL _postLocation;
	BOOL _postToTwitter;
	BOOL _postToFacebook;
	
	CLLocationManager *_locationManager;
	CLLocation *_mostRecentLocation;
	
	CLGeocoder *_geoCoder;
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
	
	[self _disableLocationUpdates];
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

	NSString *locationPath = [PLYResourceBundle() pathForResource:@"location" ofType:@"png"];
	UIImage *locationIcon = [[UIImage imageWithContentsOfFile:locationPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(locationIcon!=nil, @"Missing Location icon in resource bundle");
	
	_locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_locationButton.frame = CGRectMake(0, 0, 50, 50);
	[_locationButton setImage:locationIcon forState:UIControlStateNormal];
	[_locationButton addTarget:self action:@selector(_handleLocation:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:_locationButton];

	NSString *twitterPath = [PLYResourceBundle() pathForResource:@"twitter" ofType:@"png"];
	UIImage *twitterIcon = [[UIImage imageWithContentsOfFile:twitterPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(twitterIcon!=nil, @"Missing Twitter icon in resource bundle");

	_twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_twitterButton.frame = CGRectMake(0, 0, 50, 50);
	[_twitterButton setImage:twitterIcon forState:UIControlStateNormal];
	[_twitterButton addTarget:self action:@selector(_handleTwitter:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:_twitterButton];
	
	NSString *facebookPath = [PLYResourceBundle() pathForResource:@"facebook" ofType:@"png"];
	UIImage *facebookIcon = [[UIImage imageWithContentsOfFile:facebookPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(facebookIcon!=nil, @"Missing Facebook icon in resource bundle");
	
	_facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_facebookButton.frame = CGRectMake(0, 0, 50, 50);
	[_facebookButton setImage:facebookIcon forState:UIControlStateNormal];
	[_facebookButton addTarget:self action:@selector(_handleFacebook:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:_facebookButton];
	
	_characterRemainingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
	_characterRemainingLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	[view addSubview:_characterRemainingLabel];
	
	_addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_addressLabel.textColor = [UIColor lightGrayColor];
	[view addSubview:_addressLabel];
	
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
	_locationButton.frame = CGRectMake( CGRectGetMinX(_textView.frame), CGRectGetMaxY(_textView.frame), 50, 50);
	
	_characterRemainingLabel.frame = CGRectMake(CGRectGetMinX(_textView.frame)+10, CGRectGetMaxY(_textView.frame)-30, 50, 30);
	
	CGFloat x = CGRectGetMaxX(_locationButton.frame);
	_addressLabel.frame = CGRectMake(x, CGRectGetMaxY(_textView.frame), CGRectGetMinX(_twitterButton.frame)- x, 50);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_textView.text = _text;
	
	// location updates
	_postLocation = [[NSUserDefaults standardUserDefaults] boolForKey:PLYUserDefaultOpineComposerIncludeLocation];
	
	// need location manager to get feedback about authorization status
	if ([self _hasAlwaysInfoPlistMessage] || [self _hasWhenInUseInfoPlistMessage])
	{
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
	
		if (_postLocation)
		{
			[self _enableLocationUpdatesIfAuthorized];
		}
	}
	else
	{
		// warn developer about missing authorization message
		DTLogWarning(@"Cannot request location authorization, because both NSLocationWhenInUseUsageDescription and NSLocationAlwaysUsageDescription keys are missing from app's info.plist. Removing location button.");
		
		[_addressLabel removeFromSuperview];
		[_locationButton removeFromSuperview];
	}
	
	[self _updateSaveButtonState];
	[self _updateSocialButtons];
	[self _updateCharacterCount];
	[self _updateLocationButton];
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

- (NSInteger)_remainingCharacterCount
{
	NSString *trimmedString = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSInteger remainingChars = 140 - [trimmedString length];
	
	if (_postToTwitter)
	{
		remainingChars -= 24;
	}
	
	return remainingChars;
}

- (void)_updateSaveButtonState
{
	_saveButtonItem.enabled = [_textView.text length]>0 && [self _remainingCharacterCount]>=0;
}

- (void)_updateCharacterCount
{
	NSInteger remainingChars = [self _remainingCharacterCount];
	if (remainingChars>=0)
	{
		_characterRemainingLabel.textColor = [UIColor lightGrayColor];
	}
	else
	{
		_characterRemainingLabel.textColor = [UIColor redColor];
	}
	
	_characterRemainingLabel.text = [NSString stringWithFormat:@"%ld", remainingChars];
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

- (void)_updateLocationButton
{
	CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
	
	if (authStatus == kCLAuthorizationStatusRestricted || authStatus == kCLAuthorizationStatusDenied || (![self _hasWhenInUseInfoPlistMessage] && ![self _hasAlwaysInfoPlistMessage]))
	{
		_locationButton.enabled = NO;
		
		// gray it out even though it is enabled
		_locationButton.tintColor = [UIColor grayColor];
	}
	else
	{
		_locationButton.enabled = YES;
		
		if (_postLocation)
		{
			_locationButton.tintColor = PLYBrandColor();
		}
		else
		{
			_locationButton.tintColor = [UIColor grayColor];
		}
	}
}

- (BOOL)_hasWhenInUseInfoPlistMessage
{
	NSString *key = @"NSLocationWhenInUseUsageDescription";

	NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary *info = [bundle infoDictionary];
	
	if (info[key])
	{
		return YES;
	}
	
	NSString *localizedMessage = NSLocalizedStringWithDefaultValue(key, @"InfoPlist", bundle, @"XXX", nil);
	if (![localizedMessage isEqualToString:@"XXX"])
	{
		return YES;
	}
	
	return NO;
}

- (BOOL)_hasAlwaysInfoPlistMessage
{
	NSString *key = @"NSLocationAlwaysUsageDescription";
	NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary *info = [bundle infoDictionary];
	
	if (info[key])
	{
		return YES;
	}
	
	NSString *localizedMessage = NSLocalizedStringWithDefaultValue(key, @"InfoPlist", bundle, @"XXX", nil);
	if (![localizedMessage isEqualToString:@"XXX"])
	{
		return YES;
	}
	
	return NO;
}

- (void)_enableLocationUpdatesIfAuthorized
{
	CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
	
	if (authStatus == kCLAuthorizationStatusRestricted || authStatus == kCLAuthorizationStatusDenied)
	{
		return;
	}
	
	if (authStatus == kCLAuthorizationStatusNotDetermined)
	{
		if ([self _hasAlwaysInfoPlistMessage])
		{
			[_locationManager requestAlwaysAuthorization];
		}
		else if ([self _hasWhenInUseInfoPlistMessage])
		{
			[_locationManager requestWhenInUseAuthorization];
		}
		
		return;
	}
	
	[_locationManager startUpdatingLocation];
}

- (void)_disableLocationUpdates
{
	[_locationManager stopUpdatingLocation];
	
	_addressLabel.text = nil;
}

- (void)_updateAddressLabelWithPlacemark:(CLPlacemark *)placemark
{
	NSDictionary *addressDictionary = placemark.addressDictionary;
	
	NSMutableString *label = [NSMutableString string];
	
	NSString *subLocality = addressDictionary[@"SubLocality"];
	
	if (subLocality)
	{
		[label appendString:subLocality];
	}
	else
	{
		NSString *city = addressDictionary[@"City"];
		
		if (city)
		{
			[label appendString:city];
			
			
			NSString *country = addressDictionary[@"Country"];
			
			if (country)
			{
				[label appendString:@", "];
				[label appendString:country];
			}
		}
	}
	
	_addressLabel.text = label;
}

- (void)_updateAddressLabelWithLocation:(CLLocation *)location
{
	double latitude = location.coordinate.latitude;
	double longitude = location.coordinate.longitude;
	
	int latSeconds = (int)round(abs(latitude * 3600));
	int latDegrees = latSeconds / 3600;
	latSeconds = latSeconds % 3600;
	int latMinutes = latSeconds / 60;
	latSeconds %= 60;
	
	int longSeconds = (int)round(abs(longitude * 3600));
	int longDegrees = longSeconds / 3600;
	longSeconds = longSeconds % 3600;
	int longMinutes = longSeconds / 60;
	longSeconds %= 60;
	
	char latDirection = (latitude >= 0) ? 'N' : 'S';
	char longDirection = (longitude >= 0) ? 'E' : 'W';
	
	_addressLabel.text = [NSString stringWithFormat:@"%i° %i' %c, %i° %i' %c", latDegrees, latMinutes, latDirection, longDegrees, longMinutes, longDirection];
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
	
		if (_postLocation && _mostRecentLocation)
		{
			PLYLocationCoordinate2D loc;
			loc.latitude = _mostRecentLocation.coordinate.latitude;
			loc.longitude = _mostRecentLocation.coordinate.longitude;
			
			opine.location = loc;
		}
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

- (void)_handleLocation:(id)sender
{
	_postLocation = !_postLocation;
	
	if (_postLocation)
	{
		[self _enableLocationUpdatesIfAuthorized];
		
		if (_mostRecentLocation)
		{
			[self _updateAddressLabelWithLocation:_mostRecentLocation];
		}
	}
	else
	{
		[self _disableLocationUpdates];
	}
	
	[self _updateLocationButton];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:_postLocation forKey:PLYUserDefaultOpineComposerIncludeLocation];
	[defaults synchronize];
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
	[self _updateSaveButtonState];
	[self _updateCharacterCount];

	_language = _textView.usedInputLanguage;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation *location = [locations lastObject];
	
	if (_postLocation)
	{
		if (location.coordinate.latitude != _mostRecentLocation.coordinate.latitude ||
			 location.coordinate.longitude != _mostRecentLocation.coordinate.longitude ||
			 location.horizontalAccuracy != _mostRecentLocation.horizontalAccuracy)
		{
			_mostRecentLocation = location;
			
			if (!_geoCoder)
			{
				_geoCoder = [[CLGeocoder alloc] init];
			}
			
			[_geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
				
				if (placemarks)
				{
					[self _updateAddressLabelWithPlacemark:[placemarks firstObject]];
				}
				else
				{
					[self _updateAddressLabelWithLocation:location];
				}
			}];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted && status != kCLAuthorizationStatusNotDetermined)
	{
		[manager startUpdatingLocation];
	}

	[self _updateLocationButton];
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
