// Global Header for ProductLayerSDK

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

#import "ProductLayerUI.h"

#endif

// constant for keychain
#define PLY_SERVICE @"com.productlayer.api.auth-token"

