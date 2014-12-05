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

	#import "PLYAVFoundationFunctions.h"
	#import "UIViewController+ProductLayer.h"

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

//! Project version number for ProductLayer.
FOUNDATION_EXPORT double ProductLayerVersionNumber;

//! Project version string for ProductLayer.
FOUNDATION_EXPORT const unsigned char ProductLayerVersionString[];