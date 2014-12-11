//
//  PLYFunctions.h
//  PL
//
//  Created by Oliver Drobnik on 30/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//



#import "PLYEntities.h"
#import "PLYCompatibility.h"

/**
 Function to retrieve the PLYProduct from a passed array that best matches the preferred langauges of the user
 */
PLYProduct *PLYProductBestMatchingUserPreferredLanguages(NSArray *products);

/**
 Helper function to return the NSBundle that contains the localized strings.
 @returns The bundle to retrieve resources for ProductLayerSDK from
 */
NSBundle *PLYResourceBundle();

/**
 Convenience macro for retrieving localized strings from resource bundle
 */
#define PLYLocalizedStringFromTable(key, tbl, comment) \
NSLocalizedStringFromTableInBundle(key, tbl, PLYResourceBundle(), comment)

/**
 Standard ProductLayer color
 @returns The standard tint color to use for PL-related UI elements
 */
DTColor *PLYBrandColor();

/**
 Converts MongoDB/Java timestamp to NSDate
 */
NSDate *PLYJavaTimestampToNSDate(double timestamp);

/**
 Creates MongoDB/Java timestamp from NSDate
*/
double PLYJavaTimestampFromNSDate(NSDate *date);