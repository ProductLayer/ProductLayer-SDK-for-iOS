//
//  PLYFunctionsTest.m
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 05/12/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PLYFunctions.h"
#import "PLYCompatibility.h"
#import "ProductLayer.h"

@interface PLYFunctionsTest : XCTestCase

@end

@implementation PLYFunctionsTest

- (void)testGettingResourceBundle
{
	NSBundle *resourceBundle = PLYResourceBundle();
	XCTAssertNotNil(resourceBundle, @"Should have gotten a resource bundle");
}

- (void)testGettingStringMacro
{
	NSString *key = @"pl-brand-own-name";
	NSString *string = PLYLocalizedStringFromTable(key, @"API", nil);
	
	XCTAssertNotEqualObjects(key, string, @"Should have gotten a translation for the key");
}

- (void)testGettingBrandColor
{
	DTColor *color = PLYBrandColor();
	XCTAssertNotNil(color, @"Should have gotten the brand tint color");
}

#pragma mark - iOS Only

#if TARGET_OS_IPHONE

- (void)testGettingXIB
{
	NSBundle *resourceBundle = PLYResourceBundle();
	
	NSString *path = [resourceBundle pathForResource:@"PLYBrandPickerViewController" ofType:@"nib"];
	XCTAssertNotNil(path, @"There should be a compiled nib in the resource bundle");
}

#endif

@end
