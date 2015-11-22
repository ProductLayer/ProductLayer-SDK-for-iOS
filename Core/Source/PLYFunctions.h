//
//  PLYFunctions.h
//  PL
//
//  Created by Oliver Drobnik on 30/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "PLYEntities.h"
#import "PLYCompatibility.h"

/**
 Function to retrieve the PLYProduct from a passed array that best matches the preferred langauges of the user
 */
PLYProduct *PLYProductBestMatchingUserPreferredLanguages(NSArray *products);

/**
 Calculates a check digit for a given GTIN
 */
NSUInteger PLYCheckDigitForGTIN(NSString *GTIN);

/**
 Function to validate a GTIN
 */
BOOL PLYIsValidGTIN(NSString *GTIN);

/**
 Determines if a GTIN is globally valid
 @returns `YES` if a GTIN is globally unique
 */
BOOL PLYGTINIsValidGlobally(NSString *GTIN);

/**
 Expands a UPC-E to its UPC-A equivalent
 */
NSString *PLYUPCAFromUPCE(NSString *UPCE);

/**
 Helper function to return the NSBundle that contains the localized strings.
 @returns The bundle to retrieve resources for ProductLayerSDK from
 */
NSBundle *PLYResourceBundle();

/**
 Convenience macro for retrieving localized strings from resource bundle
 */
NSString *PLYLocalizedStringFromTable(NSString *key, NSString *tbl, NSString *comment);

/**
 Standard ProductLayer color
 @returns The standard tint color to use for PL-related UI elements
 */
DTColor *PLYBrandColor();

/**
 Sets an override color for PLYBrandColor(). If this is set to non-`nil` this is used instead
*/
void PLYBrandColorSetOverride(DTColor *color);

/**
 Gets the experience level for a point value
 @returns the floating point level
 */
double PLYLevelForPoints(NSUInteger points);

/**
 Gets the progress in the current level for a point value
 @returns the percent progress
 */
double PLYPercentProgressInLevelForPoints(NSUInteger points);
