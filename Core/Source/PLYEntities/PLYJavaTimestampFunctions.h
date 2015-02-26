//
//  PLYJavaTimestampFunctions.h
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 26.02.15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

/**
 Determines if a GTIN is globally valid
 @returns `YES` if a GTIN is globally unique
 */
BOOL PLYGTINIsValidGlobally(NSString *GTIN);

/**
 Converts MongoDB/Java timestamp to NSDate
 */
NSDate *PLYJavaTimestampToNSDate(double timestamp);

/**
 Creates MongoDB/Java timestamp from NSDate
 */
double PLYJavaTimestampFromNSDate(NSDate *date);