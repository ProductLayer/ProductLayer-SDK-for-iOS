// all-inclusive header for Product Layer API

// system headers used throughout
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

// PLY Headers
#import "PLYConstants.h"
#import "PLYServer.h"

#import "PLYOpine.h"
#import "PLYProduct.h"
#import "PLYImage.h"
#import "PLYProductCategory.h"
#import "PLYPackaging.h"
#import "PLYReview.h"
#import "PLYList.h"
#import "PLYListItem.h"
#import "PLYUser.h"
#import "PLYErrorMessage.h"
#import "PLYErrorResponse.h"

// User Interface
#import "PLYLoginViewController.h"
#import "PLYTextField.h"
#import "PLYFormValidator.h"
#import "PLYUserNameValidator.h"
#import "PLYFormEmailValidator.h"

// Scanner
#import "PLYScannerViewController.h"
#import "PLYVideoPreviewInterestBox.h"
#import "PLYVideoPreviewView.h"

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
static inline UIColor *PLYBrandColor()
{
	return [UIColor colorWithRed:110.0/256.0 green:190.0/256.0 blue:68.0/256.0 alpha:1];
}

//! Project version number for ProductLayer.
FOUNDATION_EXPORT double ProductLayerVersionNumber;

//! Project version string for ProductLayer.
FOUNDATION_EXPORT const unsigned char ProductLayerVersionString[];