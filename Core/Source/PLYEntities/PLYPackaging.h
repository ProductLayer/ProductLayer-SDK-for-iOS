//
//  PLYPackaging.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYEntity.h"

@interface PLYPackaging : PLYEntity
{
    // All what's packed into.
    NSString *contains;
    
    // The name of the package.
    NSString *name;
    
    // The package description.
    NSString *description;
    
    // The units per package.
    NSNumber *unit;

}

@property (nonatomic, copy) NSString *contains;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSNumber *unit;

@end
