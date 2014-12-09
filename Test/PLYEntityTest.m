//
//  PLYEntityTest.m
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 09/12/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PLYEntity.h"
#import "PLYErrorResponse.h"
#import "PLYErrorMessage.h"

@interface PLYEntityTest : XCTestCase

@end

@implementation PLYEntityTest


- (NSDictionary *)_dictionaryForErrorResponse
{
	return @{
				@"errors" : @[
						  @{
							  @"code": @(3007),
							  @"message": @"The gtin has an invalid length. Must be between 7-8 or 11-14 digits without leading zeros."
							  }
						  ]
				};
}

- (void)testErrorResponse
{
	NSDictionary *dict = [self _dictionaryForErrorResponse];
	PLYEntity *entity = [PLYEntity entityFromDictionary:dict];
	
	XCTAssertEqualObjects([entity class], [PLYErrorResponse class], @"Should parse to PLYErrorResponse");
}


@end
