//
//  AppSettings.m
//  PL
//
//  Created by René Swoboda on 28/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "AppSettings.h"

@implementation AppSettings

+ (NSLocale *) currentAppLocale{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appLocale = [defaults objectForKey:@"PLYLocale"];
    if (!appLocale){
        return [NSLocale currentLocale];
    }
    
    return [NSLocale localeWithLocaleIdentifier:appLocale];
}

+ (NSArray *) availableLocales{
    NSMutableArray *locales = [NSMutableArray arrayWithObjects:@"de_DE",@"de_AT", @"de_CH",@"en_US",@"en_GB", @"en_CA", nil];
    
    if(![locales containsObject:[[NSLocale currentLocale] localeIdentifier]]){
        [locales addObject:[[NSLocale currentLocale] localeIdentifier]];
    }
    
    return locales;
}

@end
