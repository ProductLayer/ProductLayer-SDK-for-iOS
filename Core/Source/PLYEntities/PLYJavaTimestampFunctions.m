//
//  PLYJavaTimestampFunctions.m
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 26.02.15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//


/**
 Creates MongoDB/Java timestamp from NSDate
 */
NSDate *PLYJavaTimestampToNSDate(double timestamp)
{
	NSTimeInterval seconds = timestamp/1000.0;
	return [NSDate dateWithTimeIntervalSince1970:seconds];
}

double PLYJavaTimestampFromNSDate(NSDate *date)
{
	NSTimeInterval seconds = [date timeIntervalSince1970];
	return seconds * 1000.0;
}