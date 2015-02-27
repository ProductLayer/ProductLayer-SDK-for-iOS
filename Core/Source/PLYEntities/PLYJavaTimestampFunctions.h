//
//  PLYJavaTimestampFunctions.h
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 26.02.15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

/**
 Converts MongoDB/Java timestamp to NSDate
 */
NSDate *PLYJavaTimestampToNSDate(double timestamp);

/**
 Creates MongoDB/Java timestamp from NSDate
 */
double PLYJavaTimestampFromNSDate(NSDate *date);