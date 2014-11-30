//
//  PLYFunctions.h
//  PL
//
//  Created by Oliver Drobnik on 30/11/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//



@class PLYProduct;

/**
 Function to retrieve the PLYProduct from a passed array that best matches the preferred langauges of the user
 */
PLYProduct *PLYProductBestMatchingUserPreferredLanguages(NSArray *products);