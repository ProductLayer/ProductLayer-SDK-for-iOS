//
//  PLYProblemReport.h
//  ProdlyApp
//
//  Created by Oliver Drobnik on 23/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYEntity.h"

/**
 Object representing a problem report about a given entity
 */
@interface PLYProblemReport : PLYEntity

/**
 A description of the problem with the entity
 */
@property (nonatomic, copy) NSString *text;

/**
 An entity reference that the complaint is about
 */
@property (nonatomic, copy) PLYEntity *entity;

@end
