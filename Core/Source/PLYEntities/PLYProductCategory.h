//
//  PLYProductCategory.h
//  PL
//
//  Created by René Swoboda on 13/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLYProductCategory : NSObject

+ (NSArray *) getAvailableMainCategories;
+ (NSArray *) getSubCategoriesForCategory:(NSString *)mainCategory;
+ (NSArray *) getAllAvailableCategories;

@end
