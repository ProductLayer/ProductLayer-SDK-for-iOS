//
//  PLYErrorResponse.h
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This object will be returned if an error occurred.
 **/
@interface PLYErrorResponse : NSObject {
    // A list of error messages.
    NSArray *errors;
}

@property (nonatomic, copy) NSArray *errors;

+ (PLYErrorResponse *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
