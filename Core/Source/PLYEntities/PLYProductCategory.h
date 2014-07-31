//
//  PLYProductCategory.h
//  PL
//
//  Created by René Swoboda on 13/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYEntity.h"

@interface PLYProductCategory : PLYEntity

+ (NSArray *) getAvailableMainCategories;
+ (NSArray *) getSubCategoriesForCategory:(NSString *)mainCategory;
+ (NSArray *) getAllAvailableCategories;

@end
