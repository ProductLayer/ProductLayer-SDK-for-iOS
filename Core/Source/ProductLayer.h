// all-inclusive header for Product Layer API

// system headers used throughout
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#if TARGET_OS_IPHONE
	#import <UIKit/UIKit.h>
#else
	#import <Cocoa/Cocoa.h>
#endif

#import "PLYCompatibility.h"

// PLY Headers
#import "PLYConstants.h"
#import "PLYFunctions.h"
#import "PLYServer.h"

#import "PLYEntities.h"


#if TARGET_OS_IPHONE

	// iOS User Interface
	#import "PLYLoginViewController.h"
	#import "PLYTextField.h"
	#import "PLYTextView.h"
	#import "PLYFormValidator.h"
	#import "PLYOpineComposeViewController.h"
	#import "PLYNonEmptyValidator.h"
	#import "PLYContentsDidChangeValidator.h"
	#import "PLYUserNameValidator.h"
	#import "PLYFormEmailValidator.h"
	#import "PLYCategoryPickerViewController.h"
	#import "PLYBrandPickerViewController.h"
	#import "PLYGuidedInputViewController.h"

	// Scanner
	#import "PLYScannerViewController.h"
	#import "PLYVideoPreviewInterestBox.h"
	#import "PLYVideoPreviewView.h"

#endif

// Localization

// helper function to return the NSBundle that contains the localized strings
static inline NSBundle *PLYResourceBundle()
{
	// bundle reference only retrieved once
	static NSBundle *_resourceBundle = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSBundle *bundle = [NSBundle bundleForClass:[PLYServer class]];
		NSString *extension = [[bundle bundlePath] pathExtension];
		
		if ([extension isEqualToString:@"app"])
		{
			// inside .app we need to get the resource bundle
			NSString *resourceBundlePath = [bundle pathForResource:@"ProductLayer" ofType:@"bundle"];
			_resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
		}
		else 	if ([extension isEqualToString:@"framework"])
		{
			// inside .framework the framework is the resource bundle
			_resourceBundle = bundle;
		}
	});
	
	return _resourceBundle;
}

#define PLYLocalizedStringFromTable(key, tbl, comment) \
NSLocalizedStringFromTableInBundle(key, tbl, PLYResourceBundle(), comment)

// standard ProductLayer color
static inline DTColor *PLYBrandColor()
{
	return [DTColor colorWithRed:110.0/256.0 green:190.0/256.0 blue:68.0/256.0 alpha:1];
}

//! Project version number for ProductLayer.
FOUNDATION_EXPORT double ProductLayerVersionNumber;

//! Project version string for ProductLayer.
FOUNDATION_EXPORT const unsigned char ProductLayerVersionString[];