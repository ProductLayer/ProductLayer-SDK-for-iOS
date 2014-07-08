//
//  PLYErrorResponse.h
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

/**
 * This object will be returned if an error occurred.
 **/
@interface PLYErrorResponse : PLYEntity
{
    // A list of error messages.
    NSArray *errors;
}

@property (nonatomic, copy) NSArray *errors;


@end
