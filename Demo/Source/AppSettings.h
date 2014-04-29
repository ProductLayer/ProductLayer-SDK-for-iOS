//
//  AppSettings.h
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

+ (NSLocale *) currentAppLocale;
+ (NSArray *) availableLocales;

@end
