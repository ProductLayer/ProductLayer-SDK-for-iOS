//
//  DTOpineComposeViewController.m
//  HungryScanner
//
//  Created by Oliver Drobnik on 23/10/14.
//  Copyright (c) 2014 Product Layer. All rights reserved.
//

#import "PLYOpineComposeViewController.h"
#import "PLYSocialConnectionViewController.h"
#import "PLYLoginViewController.h"

#import "UIViewController+ProductLayer.h"
#import <CoreLocation/CoreLocation.h>

#import "ProductLayerUI.h"

#import <DTFoundation/DTBlockFunctions.h>
#import <DTFoundation/DTLog.h>


@interface PLYOpineComposeViewController () <UITextViewDelegate,  // for tracking entered text
															CLLocationManagerDelegate, // for attaching location
															UIImagePickerControllerDelegate,
                                             UINavigationControllerDelegate>  // for image picker

@end

@implementation PLYOpineComposeViewController
{
	
	// Nav Bar
	UIBarButtonItem *_saveButtonItem;
	UIBarButtonItem *_cancelButtonItem;
	
	// UI
	UIView *_frameView;
	PLYTextView *_textView;
	UIButton *_twitterButton;
	UIButton *_facebookButton;
	UIButton *_locationButton;
	UIButton *_photoButton;
	UILabel *_addressLabel;
	UILabel *_characterRemainingLabel;
	
	UILabel *_productNameLabel;
	
	// location
	CLLocationManager *_locationManager;
	CLLocation *_mostRecentLocation;
	CLGeocoder *_geoCoder;

	PLYOpine *_opine;
	BOOL _postLocation;
	
	// images
	NSMutableArray *_attachedImages;
	
	NSLayoutConstraint *_bottomMarginConstraint;
	NSLayoutConstraint *_belowProductLabelConstraint;
}

+ (void)initialize
{
	[super initialize];
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSDictionary *defaults = @{@"PLYShareOnTwitter": @(YES),
											@"PLYShareOnFacebook": @(YES)};
		[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	});
}

- (instancetype)initWithOpine:(PLYOpine *)opine
{
	self = [super init];
	
	if (self)
	{
		if (opine)
		{
			_opine = [opine copy];
			
			_attachedImages = [NSMutableArray arrayWithArray:_opine.images];
		}
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
	UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
	view.backgroundColor = [UIColor whiteColor];
	
	_frameView = [[UIView alloc] initWithFrame:CGRectZero];
	_frameView.translatesAutoresizingMaskIntoConstraints = NO;
	_frameView.layer.borderColor = PLYBrandColor().CGColor;
	_frameView.layer.borderWidth = 1;
	_frameView.layer.cornerRadius = 10;
	_frameView.clipsToBounds = YES;
	[view addSubview:_frameView];
	
	
	_textView = [[PLYTextView alloc] initWithFrame:CGRectZero];
	_textView.translatesAutoresizingMaskIntoConstraints = NO;
	_textView.delegate = self;
	_textView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 0, 0);
	_textView.keyboardType = UIKeyboardTypeDefault;
	[_frameView addSubview:_textView];
	
	_textView.text = self.opine.text;
	
	[_frameView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0
																	  constant:5]];

	[_frameView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeRight
																			relatedBy:NSLayoutRelationEqual
																				toItem:_frameView
																			attribute:NSLayoutAttributeRight
																		  multiplier:1.0
																			 constant:-5]];

	[_frameView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeTop
																			relatedBy:NSLayoutRelationEqual
																				toItem:_frameView
																			attribute:NSLayoutAttributeTop
																		  multiplier:1.0
																			 constant:0]];
	
	NSString *locationPath = [PLYResourceBundle() pathForResource:@"location" ofType:@"png"];
	UIImage *locationIcon = [[UIImage imageWithContentsOfFile:locationPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(locationIcon!=nil, @"Missing Location icon in resource bundle");
	
	_locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_locationButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_locationButton setImage:locationIcon forState:UIControlStateNormal];
	[_locationButton addTarget:self action:@selector(_handleLocation:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:_locationButton];
	
	_addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_addressLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_addressLabel.textColor = [UIColor lightGrayColor];
	[view addSubview:_addressLabel];

	NSString *twitterPath = [PLYResourceBundle() pathForResource:@"twitter" ofType:@"png"];
	UIImage *twitterIcon = [[UIImage imageWithContentsOfFile:twitterPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(twitterIcon!=nil, @"Missing Twitter icon in resource bundle");

	_twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_twitterButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_twitterButton setImage:twitterIcon forState:UIControlStateNormal];
	[_twitterButton addTarget:self action:@selector(_handleTwitter:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:_twitterButton];
	
	NSString *facebookPath = [PLYResourceBundle() pathForResource:@"facebook" ofType:@"png"];
	UIImage *facebookIcon = [[UIImage imageWithContentsOfFile:facebookPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(facebookIcon!=nil, @"Missing Facebook icon in resource bundle");
	
	_facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_facebookButton.translatesAutoresizingMaskIntoConstraints = NO;
	[_facebookButton setImage:facebookIcon forState:UIControlStateNormal];
	[_facebookButton addTarget:self action:@selector(_handleFacebook:) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview:_facebookButton];
	
	_characterRemainingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_characterRemainingLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[_frameView addSubview:_characterRemainingLabel];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_characterRemainingLabel attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_textView
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0
																	  constant:5]];
	
	NSString *cameraIconPath = [PLYResourceBundle() pathForResource:@"camera-icon" ofType:@"png"];
	UIImage *cameraIcon = [[UIImage imageWithContentsOfFile:cameraIconPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	NSAssert(cameraIconPath!=nil, @"Missing Camera icon in resource bundle");
	
	_photoButton = [UIButton buttonWithType:UIButtonTypeSystem];
	_photoButton.translatesAutoresizingMaskIntoConstraints = NO;
	_photoButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
	[_photoButton setTitle:@" 0" forState:UIControlStateNormal];
	[_photoButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
	[_photoButton setImage:cameraIcon forState:UIControlStateNormal];
	[_photoButton addTarget:self action:@selector(_handlePhoto:) forControlEvents:UIControlEventTouchUpInside];
	[_frameView addSubview:_photoButton];
	
	
	_productNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_productNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
	_productNameLabel.textColor = PLYBrandColor();
	[view addSubview:_productNameLabel];
	
	self.view = view;

	[self _updateLabelFonts];
	
	// product name label
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_productNameLabel attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_textView
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0
																	  constant:0]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_productNameLabel attribute:NSLayoutAttributeRight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_textView
																	 attribute:NSLayoutAttributeRight
																	multiplier:1.0
																	  constant:0]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_productNameLabel attribute:NSLayoutAttributeTop
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:self.topLayoutGuide
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:10]];
	
	_belowProductLabelConstraint = [NSLayoutConstraint constraintWithItem:_frameView attribute:NSLayoutAttributeTop
																					relatedBy:NSLayoutRelationEqual
																						toItem:_productNameLabel
																					attribute:NSLayoutAttributeBottom
																				  multiplier:1.0
																					 constant:5];
	[view addConstraint:_belowProductLabelConstraint];
	
	// photo button
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_photoButton attribute:NSLayoutAttributeRight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeRight
																	multiplier:1.0
																	  constant:0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:_photoButton attribute:NSLayoutAttributeBottom
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:5]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_photoButton attribute:NSLayoutAttributeBottom
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_characterRemainingLabel
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:_photoButton attribute:NSLayoutAttributeCenterY
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_characterRemainingLabel
																	 attribute:NSLayoutAttributeCenterY
																	multiplier:1.0
																	  constant:0]];

	[_frameView addConstraint:[NSLayoutConstraint constraintWithItem:_textView attribute:NSLayoutAttributeBottom
																			 relatedBy:NSLayoutRelationEqual
																				 toItem:_photoButton
																			 attribute:NSLayoutAttributeTop
																			multiplier:1.0
																			  constant:5]];
	

	[_facebookButton addConstraint:[NSLayoutConstraint constraintWithItem:_facebookButton attribute:NSLayoutAttributeWidth
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:40]];

	[_facebookButton addConstraint:[NSLayoutConstraint constraintWithItem:_facebookButton attribute:NSLayoutAttributeHeight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:50]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_facebookButton attribute:NSLayoutAttributeRight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeRight
																	multiplier:1.0
																	  constant:0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:_facebookButton attribute:NSLayoutAttributeTop
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:0]];
	
	[_twitterButton addConstraint:[NSLayoutConstraint constraintWithItem:_twitterButton attribute:NSLayoutAttributeWidth
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:40]];
	
	[_twitterButton addConstraint:[NSLayoutConstraint constraintWithItem:_twitterButton attribute:NSLayoutAttributeHeight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:50]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_twitterButton attribute:NSLayoutAttributeRight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_facebookButton
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0
																	  constant:0]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_twitterButton attribute:NSLayoutAttributeTop
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:0]];

	[_locationButton addConstraint:[NSLayoutConstraint constraintWithItem:_locationButton attribute:NSLayoutAttributeWidth
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:40]];
	
	[_locationButton addConstraint:[NSLayoutConstraint constraintWithItem:_locationButton attribute:NSLayoutAttributeHeight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:50]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_locationButton attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0
																	  constant:0]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_locationButton attribute:NSLayoutAttributeTop
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:0]];
	
	[_addressLabel addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeHeight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:50]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_locationButton
																	 attribute:NSLayoutAttributeRight
																	multiplier:1.0
																	  constant:0]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeRight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_twitterButton
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0
																	  constant:0]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_addressLabel attribute:NSLayoutAttributeTop
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:_frameView
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0
																	  constant:0]];
	
	[view addConstraint:[NSLayoutConstraint constraintWithItem:_frameView attribute:NSLayoutAttributeLeft
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:view
																	 attribute:NSLayoutAttributeLeft
																	multiplier:1.0
																	  constant:10]];

	[view addConstraint:[NSLayoutConstraint constraintWithItem:_frameView attribute:NSLayoutAttributeRight
																	 relatedBy:NSLayoutRelationEqual
																		 toItem:view
																	 attribute:NSLayoutAttributeRight
																	multiplier:1.0
																	  constant:-10]];
	
	
	_bottomMarginConstraint = [NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide
																			 attribute:NSLayoutAttributeTop
																			 relatedBy:NSLayoutRelationEqual
																				 toItem:_facebookButton
																			 attribute:NSLayoutAttributeBottom
																			multiplier:1.0
																			  constant:0];
	_bottomMarginConstraint.priority = UILayoutPriorityDefaultHigh;
	[view addConstraint:_bottomMarginConstraint];

	
	self.navigationItem.title = PLYLocalizedStringFromTable(@"OPINE_COMPOSER_TITLE", @"UI", @"Title of opine composer");
	
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelItem;
	
	_saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = _saveButtonItem;
	
	self.automaticallyAdjustsScrollViewInsets = NO;
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	// observe the logged in user
	[self.productLayerServer addObserver:self forKeyPath:@"loggedInUser" options:NSKeyValueObservingOptionNew context:NULL];
	
	// observe the font size
	[[NSNotificationCenter defaultCenter] addObserver:self
														  selector:@selector(_didChangePreferredContentSize:)
																name:UIContentSizeCategoryDidChangeNotification
															 object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
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
	[self _updatePhotoButton];
	[self _updateProductNameLabel];
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

- (void)_updateSaveButtonState
{
	_saveButtonItem.enabled = [_textView.text length]>0;
}

- (void)_updateCharacterCount
{
    NSString *trimmedString = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger count = trimmedString.length;

	_characterRemainingLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
}

- (BOOL)_hasSocialConnection:(NSString *)service
{
	return [self.productLayerServer.loggedInUser.socialConnections[service] boolValue];
}

- (void)_showSocialConnections
{
	PLYSocialConnectionViewController *social = [PLYSocialConnectionViewController new];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:social];
	
	social.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_closeSocialConnections)];
	
	[self presentViewController:nav animated:YES completion:NULL];
}

- (void)_closeSocialConnections
{
	[self dismissViewControllerAnimated:YES completion:^{
		if (!self.opine.shareOnFacebook && [self _hasSocialConnection:@"facebook"])
		{
			self.opine.shareOnFacebook = YES;
		}

		if (!self.opine.shareOnTwitter && [self _hasSocialConnection:@"twitter"])
		{
			self.opine.shareOnTwitter = YES;
		}
		
		[self _updateSocialButtons];
		[self _saveSocialButtonState];
	}];
}

- (void)_updateSocialButtons
{
	if (![self _hasSocialConnection:@"twitter"])
	{
		self.opine.shareOnTwitter = NO;
	}
	
	if (![self _hasSocialConnection:@"facebook"])
	{
		self.opine.shareOnFacebook = NO;
	}
	
	if (self.opine.shareOnFacebook)
	{
		_facebookButton.tintColor = PLYBrandColor();
	}
	else
	{
		_facebookButton.tintColor = [UIColor grayColor];
	}
	
	if (self.opine.shareOnTwitter)
	{
		_twitterButton.tintColor = PLYBrandColor();
	}
	else
	{
		_twitterButton.tintColor = [UIColor grayColor];
	}
}

- (void)_saveSocialButtonState
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:self.opine.shareOnTwitter forKey:@"PLYShareOnTwitter"];
	[defaults setBool:self.opine.shareOnFacebook forKey:@"PLYShareOnFacebook"];
	[defaults synchronize];
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

- (void)_updateAddressLabelWithAddressFromPlacemark:(CLPlacemark *)placemark
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

- (void)_updateAddressWithLatLongFromLocation:(CLLocation *)location
{
	double latitude = location.coordinate.latitude;
	double longitude = location.coordinate.longitude;
	
	int latSeconds = (int)round(fabs(latitude * 3600));
	int latDegrees = latSeconds / 3600;
	latSeconds = latSeconds % 3600;
	int latMinutes = latSeconds / 60;
	latSeconds %= 60;
	
	int longSeconds = (int)round(fabs(longitude * 3600));
	int longDegrees = longSeconds / 3600;
	longSeconds = longSeconds % 3600;
	int longMinutes = longSeconds / 60;
	longSeconds %= 60;
	
	char latDirection = (latitude >= 0) ? 'N' : 'S';
	char longDirection = (longitude >= 0) ? 'E' : 'W';
	
	_addressLabel.text = [NSString stringWithFormat:@"%i° %i' %c, %i° %i' %c", latDegrees, latMinutes, latDirection, longDegrees, longMinutes, longDirection];
}

- (void)_updateAddressLabelFromLocation:(CLLocation *)location
{
	if (!_geoCoder)
	{
		_geoCoder = [[CLGeocoder alloc] init];
	}
	
	[_geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		
		// prevent late arrivals
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			
			if (!_postLocation)
			{
				_addressLabel.text = nil;
				return;
			}
			
			if (placemarks)
			{
				[self _updateAddressLabelWithAddressFromPlacemark:[placemarks firstObject]];
			}
			else
			{
				[self _updateAddressWithLatLongFromLocation:location];
			}
		});
	}];
}

- (void)_updatePhotoButton
{
	NSString *title = [NSString stringWithFormat:@" %ld", (unsigned long)[_attachedImages count]];
	[_photoButton setTitle:title forState:UIControlStateNormal];
}

- (void)_updateProductNameLabel
{
	_productNameLabel.text = _productName;
	
	if ([_productName length])
	{
		_belowProductLabelConstraint.constant = 5;
	}
	else
	{
		_belowProductLabelConstraint.constant = 0;
	}
}

- (void)_updateLabelFonts
{
	_textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	_characterRemainingLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	_productNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	_addressLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
	_photoButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
	if ([_delegate respondsToSelector:@selector(opineComposeViewControllerDidCancel:)])
	{
		[_delegate opineComposeViewControllerDidCancel:self];
	}
	else
	{
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (void)save:(id)sender
{
	[_textView resignFirstResponder];
	
	NSString *newText = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// return nil if there is no text
	if ([newText length])
	{
		if (![self.opine.text isEqualToString:newText])
		{
			self.opine.text = newText;
			self.opine.language = _textView.usedInputLanguage;
		}
	
		if (_postLocation && _mostRecentLocation)
		{
			PLYLocationCoordinate2D loc;
			loc.latitude = _mostRecentLocation.coordinate.latitude;
			loc.longitude = _mostRecentLocation.coordinate.longitude;
			
			self.opine.location = loc;
		}
	}
	
	if ([_attachedImages count])
	{
		self.opine.images = _attachedImages;
	}
	else
	{
		self.opine.images = nil;
	}
	
	if ([_delegate respondsToSelector:@selector(opineComposeViewController:didFinishWithOpine:)])
	{
		[_delegate opineComposeViewController:self didFinishWithOpine:_opine];
	}
	else
	{
		// no delegate, so we are in charge
		[self dismissViewControllerAnimated:YES completion:NULL];
	}
}

- (void)_handleTwitter:(id)sender
{
	if (!self.productLayerServer.loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				[self _handleTwitter:sender];
			}
		}];
		
		return;
	}
	
	if ([self _hasSocialConnection:@"twitter"])
	{
		self.opine.shareOnTwitter = !self.opine.shareOnTwitter;
	
		[self _updateSocialButtons];
		[self _updateCharacterCount];
		[self _saveSocialButtonState];
		
		return;
	}
	
	// after returning activate the button if possible
	[self _showSocialConnections];
}

- (void)_handleFacebook:(id)sender
{
	if (!self.productLayerServer.loggedInUser)
	{
		[PLYLoginViewController presentLoginWithExplanation:nil completion:^(BOOL success) {
			if (success)
			{
				[self _handleFacebook:sender];
			}
		}];
		
		return;
	}
	
	if ([self _hasSocialConnection:@"facebook"])
	{
		self.opine.shareOnFacebook = !self.opine.shareOnFacebook;
		[self _updateSocialButtons];
		[self _updateCharacterCount];
		[self _saveSocialButtonState];
		
		return;
	}

	// after returning activate the button if possible
	[self _showSocialConnections];
}

- (void)_handleLocation:(id)sender
{
	_postLocation = !_postLocation;
	
	if (_postLocation)
	{
		[self _enableLocationUpdatesIfAuthorized];
		
		if (_mostRecentLocation)
		{
			[self _updateAddressLabelFromLocation:_mostRecentLocation];
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

- (void)_handlePhoto:(id)sender
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:PLYLocalizedStringFromTable(@"OPINE_PHOTO_ACTIONS_TITLE", @"UI", @"Title for actions menu from opine photo button") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
    if ([sender isKindOfClass:[UIBarButtonItem class]])
    {
        alert.popoverPresentationController.barButtonItem = sender;
    }
    else if ([sender isKindOfClass:[UIView class]])
    {
        UIView *view = (UIView *)sender;
        alert.popoverPresentationController.sourceView = view;
        alert.popoverPresentationController.sourceRect = view.bounds;
    }
    
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		NSString *text = PLYLocalizedStringFromTable(@"OPINE_IMAGE_FROM_CAM", @"UI", @"Add new opine image from camera");
		UIAlertAction *newPhotoAction = [UIAlertAction actionWithTitle:text style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			picker.delegate = self;
            picker.modalPresentationStyle = UIModalPresentationFullScreen;
			
			[self presentViewController:picker animated:YES completion:NULL];
		}];
		
		[alert addAction:newPhotoAction];
	}
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		NSString *text = PLYLocalizedStringFromTable(@"OPINE_IMAGE_FROM_LIBRARY", @"UI", @"Select new opine image from library");
		UIAlertAction *updateAvatar = [UIAlertAction actionWithTitle:text style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			UIImagePickerController *picker = [[UIImagePickerController alloc] init];
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			picker.delegate = self;
			
			[self presentViewController:picker animated:YES completion:NULL];
		}];
		
		[alert addAction:updateAvatar];
	}
	
	if ([_attachedImages count])
	{
		NSString *text  = PLYLocalizedStringFromTable(@"OPINE_DELETE_IMAGES_ACTION", @"UI", @"Option to delete all opine attachments");
		UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:text style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
			_attachedImages = nil;
			[self _updatePhotoButton];
		}];
		
		[alert addAction:deleteAction];
	}
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_CANCEL", @"UI", @"To cancel something") style:UIAlertActionStyleCancel handler:NULL];
	[alert addAction:cancelAction];
	
	[self presentViewController:alert animated:YES completion:NULL];
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
 
	// set inset to make up for covered height at bottom
	_bottomMarginConstraint.constant = coveredFrame.size.height;
	
	NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	NSUInteger options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
	
	[UIView animateWithDuration:duration
								 delay:0
							  options:options | UIViewAnimationOptionBeginFromCurrentState
						  animations:^{
							  [self.view layoutIfNeeded];
						  } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	// set inset to make up for no longer covered array at bottom
	_bottomMarginConstraint.constant = 0;
	
	NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	NSUInteger options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
	
	[UIView animateWithDuration:duration
								 delay:0
							  options:options | UIViewAnimationOptionBeginFromCurrentState
						  animations:^{
							  [self.view layoutIfNeeded];
						  } completion:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		[self _updateSocialButtons];
	});
}

- (void)_didChangePreferredContentSize:(NSNotification *)notification
{
	[self _updateLabelFonts];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
	[self _updateSaveButtonState];
	[self _updateCharacterCount];

	self.opine.language = _textView.usedInputLanguage;
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
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				[self _updateAddressLabelFromLocation:location];
			});
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted && status != kCLAuthorizationStatusNotDetermined)
	{
		[manager startUpdatingLocation];
	}
	else
	{
		// remove previous contents
		_addressLabel.text = nil;
	}

	[self _updateLocationButton];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = info[UIImagePickerControllerOriginalImage];
	
	if (!_attachedImages)
	{
		_attachedImages = [NSMutableArray new];
	}
	
	// put the image into an upload image
	PLYUploadImage *plyImage = [[PLYUploadImage alloc] initWithImageData:UIImageJPEGRepresentation(image, 0.81)];
	[_attachedImages addObject:plyImage];
	
	[self _updatePhotoButton];
	
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:nil];
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
	_opine = [opine copy];
	_attachedImages = [NSMutableArray arrayWithArray:_opine.images];
	[self _updatePhotoButton];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	_opine.shareOnFacebook = [defaults boolForKey:@"PLYShareOnFacebook"];
	_opine.shareOnTwitter = [defaults boolForKey:@"PLYShareOnTwitter"];
	
	if (opine.location.latitude || opine.location.longitude)
	{
		_mostRecentLocation = [[CLLocation alloc] initWithLatitude:opine.location.latitude longitude:opine.location.longitude];
		
		[self _updateAddressLabelFromLocation:_mostRecentLocation];
	}
}

- (void)setProductName:(NSString *)productName
{
	_productName = [productName copy];
	
	[self _updateProductNameLabel];
}

- (PLYOpine *)opine
{
	if (!_opine)
	{
		// need an opine to store edited values in
		_opine = [PLYOpine new];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		_opine.shareOnFacebook = [defaults boolForKey:@"PLYShareOnFacebook"];
		_opine.shareOnTwitter = [defaults boolForKey:@"PLYShareOnTwitter"];
	}
	
	return _opine;
}

@end
