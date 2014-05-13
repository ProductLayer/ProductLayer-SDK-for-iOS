//
//  PLYProductCategory.m
//  PL
//
//  Created by René Swoboda on 13/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "plYProductCategory.h"

@implementation PLYProductCategory

+ (NSArray *) getAvailableMainCategories{
    NSArray *categories = [PLYProductCategory getAllAvailableCategories];
    NSMutableArray *mainCategories = [NSMutableArray arrayWithCapacity:1];
    
    for(NSString *category in categories){
        if([[category componentsSeparatedByString: @"-"] count] == 4){
            [mainCategories addObject:category];
        }
    }
    
    return mainCategories;
}

+ (NSArray *) getSubCategoriesForCategory:(NSString *)mainCategory{
    NSArray *categories = [PLYProductCategory getAllAvailableCategories];
    NSMutableArray *subCategories = [NSMutableArray arrayWithCapacity:1];
    
    for(NSString *category in categories){
        if([category rangeOfString:mainCategory].location != NSNotFound && ![category isEqualToString:mainCategory]){
            [subCategories addObject:category];
        }
    }
    
    return subCategories;
}

+ (NSArray *) getAllAvailableCategories{
    /* Each category is validated by the server. So if are adding a category here
       the server wont accept it if it's not avalaible at the server side. If you 
       need another category, contact support@productlayer.com and we will add it. */
    NSArray *categories = [NSMutableArray arrayWithObjects:
                           @"pl-prod-cat-magazines",
                           @"pl-prod-cat-books",
                           @"pl-prod-cat-books-children_and_teenagers",
                           @"pl-prod-cat-books-comics_and_picturestories",
                           @"pl-prod-cat-books-computer_and_internet",
                           @"pl-prod-cat-books-economy_investments",
                           @"pl-prod-cat-books-health_mind_and_body",
                           @"pl-prod-cat-books-mystery_suspense",
                           @"pl-prod-cat-books-novel_stories",
                           @"pl-prod-cat-books-religious_spirituality",
                           @"pl-prod-cat-books-romance",
                           @"pl-prod-cat-books-sciencefiction_and_fantasy",
                           @"pl-prod-cat-clothes",
                           @"pl-prod-cat-clothes-jeans",
                           @"pl-prod-cat-clothes-pants",
                           @"pl-prod-cat-clothes-shirts",
                           @"pl-prod-cat-clothes-suites",
                           @"pl-prod-cat-clothes-underwear",
                           @"pl-prod-cat-drinks",
                           @"pl-prod-cat-drinks-alcoholic",
                           @"pl-prod-cat-drinks-non_alcoholic",
                           @"pl-prod-cat-electronic",
                           @"pl-prod-cat-electronic-camera",
                           @"pl-prod-cat-electronic-computer",
                           @"pl-prod-cat-electronic-computer-notebook",
                           @"pl-prod-cat-electronic-computer-tablet",
                           @"pl-prod-cat-electronic-computer-systems",
                           @"pl-prod-cat-electronic-computer-components",
                           @"pl-prod-cat-electronic-computer-audio",
                           @"pl-prod-cat-electronic-computer-video",
                           @"pl-prod-cat-electronic-computer-mainboard",
                           @"pl-prod-cat-electronic-computer-monitor",
                           @"pl-prod-cat-electronic-computer-network",
                           @"pl-prod-cat-electronic-computer-cpu",
                           @"pl-prod-cat-electronic-computer-ram",
                           @"pl-prod-cat-electronic-computer-storage",
                           @"pl-prod-cat-electronic-computer-graphic_card",
                           @"pl-prod-cat-electronic-computer-input_device",
                           @"pl-prod-cat-electronic-computer-cable",
                           @"pl-prod-cat-electronic-phones",
                           @"pl-prod-cat-electronic-tv",
                           @"pl-prod-cat-electronic-wearables",
                           @"pl-prod-cat-electronic-printer_and_scanner",
                           @"pl-prod-cat-electronic-printer_and_scanner-3dprinter",
                           @"pl-prod-cat-electronic-printer_and_scanner-scanner",
                           @"pl-prod-cat-electronic-printer_and_scanner-printer",
                           @"pl-prod-cat-electronic-printer_and_scanner-barcode_printer",
                           @"pl-prod-cat-electronic-printer_and_scanner-barcode_scanner",
                           @"pl-prod-cat-electronic-printer_and_scanner-scanner_accessories",
                           @"pl-prod-cat-electronic-printer_and_scanner-printer_accessories",
                           @"pl-prod-cat-food",
                           @"pl-prod-cat-food-dairy",
                           @"pl-prod-cat-food-fruit",
                           @"pl-prod-cat-food-grains",
                           @"pl-prod-cat-food-meat",
                           @"pl-prod-cat-food-sweets",
                           @"pl-prod-cat-food-vegetables",
                           @"pl-prod-cat-food-instant_meal",
                           @"pl-prod-cat-health_and_personal_care",
                           @"pl-prod-cat-health_and_personal_care-beauty",
                           @"pl-prod-cat-home_and_kitchen",
                           @"pl-prod-cat-industrial_and_scientific",
                           @"pl-prod-cat-others", nil];
    
    return categories;
}

@end
