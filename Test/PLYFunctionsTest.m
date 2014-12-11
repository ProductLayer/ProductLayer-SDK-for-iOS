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

- (void)testDecodeTimestamp
{
	double timestamp = 1418133077783.0;
	
	NSDate *date = PLYJavaTimestampToNSDate(timestamp);
	
	NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	
	NSDateComponents *comps = [cal components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
	
	XCTAssertEqual(comps.day, 9, @"Day is wrong");
	XCTAssertEqual(comps.month, 12, @"Month is wrong");
	XCTAssertEqual(comps.year, 2014, @"Year is wrong");
	XCTAssertEqual(comps.hour, 13	, @"Hour is wrong");
	XCTAssertEqual(comps.minute, 51, @"Minute is wrong");
	XCTAssertEqual(comps.second, 17, @"Second is wrong");
}

- (void)testEncodeTimestamp
{
	NSDateComponents *comps = [NSDateComponents new];
	comps.day = 9;
	comps.month = 12;
	comps.year = 2014;
	comps.hour = 13;
	comps.minute = 51;
	comps.second = 17;
	
	NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
	cal.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	
	NSDate *date = [cal dateFromComponents:comps];
	
	double timestamp = PLYJavaTimestampFromNSDate(date);
	
	XCTAssertEqual(timestamp, 1418133077000.0, @"Time stamp is wrong");
}

- (void)testTimestampRoundtrip
{
	double timestamp = 1418133077783.0;
	NSDate *date = PLYJavaTimestampToNSDate(timestamp);
	double result = PLYJavaTimestampFromNSDate(date);
	
	XCTAssertEqual(result, timestamp, @"result should be equal to start value");
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
