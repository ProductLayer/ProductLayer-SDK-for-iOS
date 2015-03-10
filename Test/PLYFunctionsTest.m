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
#import "PLYJavaTimestampFunctions.h"
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

#pragma mark - PLYGTINIsValidGlobally

- (void)testPrefix010
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"0123456789123");
	XCTAssertTrue(b, @"010 should be globally valid");
	
	// GTIN-12
	b = PLYGTINIsValidGlobally(@"123456789123");
	XCTAssertTrue(b, @"010 should be globally valid");
}

- (void)testPrefix022
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"0223456789123");
	XCTAssertFalse(b, @"022 should not be globally valid");
	
	// GTIN-12
	b = PLYGTINIsValidGlobally(@"223456789123");
	XCTAssertFalse(b, @"022 should not be globally valid");
}

- (void)testPrefix033
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"0333456789123");
	XCTAssertTrue(b, @"033 should be globally valid");
	
	// GTIN-12
	b = PLYGTINIsValidGlobally(@"133456789123");
	XCTAssertTrue(b, @"033 should be globally valid");
}

- (void)testPrefix041
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"0413456789123");
	XCTAssertFalse(b, @"041 should not be globally valid");
	
	// GTIN-12
	b = PLYGTINIsValidGlobally(@"413456789123");
	XCTAssertFalse(b, @"041 should not be globally valid");
}

- (void)testPrefix059
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"0593456789123");
	XCTAssertFalse(b, @"059 should not be globally valid");
	
	// GTIN-12
	b = PLYGTINIsValidGlobally(@"593456789123");
	XCTAssertFalse(b, @"059 should not be globally valid");
}

- (void)testPrefix081
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"0813456789123");
	XCTAssertTrue(b, @"081 should be globally valid");
	
	// GTIN-12
	b = PLYGTINIsValidGlobally(@"813456789123");
	XCTAssertTrue(b, @"081 should be globally valid");
}

- (void)testPrefix199
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"1993456789123");
	XCTAssertTrue(b, @"199 should be globally valid");
}

- (void)testPrefix20
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"2093456789123");
	XCTAssertFalse(b, @"20 should not be globally valid");
}

- (void)testPrefix300
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"3003456789123");
	XCTAssertTrue(b, @"300 should be globally valid");
}

- (void)testPrefix976
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"9763456789123");
	XCTAssertTrue(b, @"976 should be globally valid");
}

- (void)testPrefix977
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"9773456789123");
	XCTAssertTrue(b, @"977 should be globally valid");
}

- (void)testPrefix978
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"9783456789123");
	XCTAssertTrue(b, @"978 should be globally valid");
}

- (void)testPrefix980
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"9803456789123");
	XCTAssertFalse(b, @"980 should not be globally valid");
}

- (void)testPrefix981
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"9813456789123");
	XCTAssertFalse(b, @"981 should not be globally valid");
}

- (void)testPrefix985
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"9853456789123");
	XCTAssertFalse(b, @"985 should not be globally valid");
}

- (void)testPrefix99
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"9953456789123");
	XCTAssertFalse(b, @"99 should not be globally valid");
}

- (void)testGTIN8_Prefix0
{
	// GTIN-13
	BOOL b = PLYGTINIsValidGlobally(@"01234567");
	XCTAssertFalse(b, @"0 should not be globally valid");
}

- (void)testGTIN8_Prefix100_139
{
	// GTIN-8
	BOOL b = PLYGTINIsValidGlobally(@"10034567");
	XCTAssertTrue(b, @"100 should be globally valid");
	
	b = PLYGTINIsValidGlobally(@"13934567");
	XCTAssertTrue(b, @"139 should be globally valid");
}

- (void)testGTIN8_Prefix140_199
{
	// GTIN-8
	BOOL b = PLYGTINIsValidGlobally(@"14034567");
	XCTAssertFalse(b, @"140 should not be globally valid");
	
	b = PLYGTINIsValidGlobally(@"19934567");
	XCTAssertFalse(b, @"199 should not be globally valid");
}

- (void)testGTIN8_Prefix2
{
	// GTIN-8
	BOOL b = PLYGTINIsValidGlobally(@"24034567");
	XCTAssertFalse(b, @"2 should not be globally valid");
}

- (void)testGTIN8_Prefix300_969
{
	// GTIN-8
	BOOL b = PLYGTINIsValidGlobally(@"30034567");
	XCTAssertTrue(b, @"300 should be globally valid");
	
	b = PLYGTINIsValidGlobally(@"96934567");
	XCTAssertTrue(b, @"969 should be globally valid");
}

- (void)testGTIN8_Prefix97_99
{
	// GTIN-8
	BOOL b = PLYGTINIsValidGlobally(@"97034567");
	XCTAssertFalse(b, @"97 should not be globally valid");
	
	b = PLYGTINIsValidGlobally(@"98034567");
	XCTAssertFalse(b, @"98 should not be globally valid");

	b = PLYGTINIsValidGlobally(@"99034567");
	XCTAssertFalse(b, @"99 should not be globally valid");
}

- (void)testWrongGTINLength
{
	XCTAssertThrows(PLYGTINIsValidGlobally(@"123"));
}


#pragma mark - Test UPC-E

- (void)testUPCE1
{
	NSString *UPCE = @"01236432";
	NSString *UPCA = PLYUPCAFromUPCE(UPCE);
	
	XCTAssertEqualObjects(UPCA, @"012300000642", @"Incorrect expansion value");
}

- (void)testUPCE2
{
	NSString *UPCE = @"04252614";
	NSString *UPCA = PLYUPCAFromUPCE(UPCE);
	
	XCTAssertEqualObjects(UPCA, @"042100005264", @"Incorrect expansion value");
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
