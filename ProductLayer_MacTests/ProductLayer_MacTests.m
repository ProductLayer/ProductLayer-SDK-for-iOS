//
//  ProductLayer_MacTests.m
//  ProductLayer_MacTests
//
//  Created by Oliver Drobnik on 30/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface ProductLayer_MacTests : XCTestCase

@end

@implementation ProductLayer_MacTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
