//
//  PLYListItem.m
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "PLYListItem.h"

#import "DTLog.h"

@implementation PLYListItem

@synthesize gtin;
@synthesize note;
@synthesize count;
@synthesize prio;

+ (NSString *) classIdentifier{
    return @"com.productlayer.core.domain.beans.lists.ProductListItem";
}

+ (PLYListItem *)instanceFromDictionary:(NSDictionary *)aDictionary {
    
    NSString *class = [aDictionary objectForKey:@"pl-class"];
    
    // Check if class identifier is valid for parsing.
    if(class != nil && [class isEqualToString: [PLYListItem classIdentifier]]){
        PLYListItem *instance = [[PLYListItem alloc] init];
        [instance setAttributesFromDictionary:aDictionary];
        return instance;
    }
    
    DTLogError(@"No valid classIdentifier found for PLYListItem in dictionary: %@", aDictionary);
    
    return nil;
}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {
    
    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    [self setValuesForKeysWithDictionary:aDictionary];
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"pl-prod-gtin"]) {
        [self setValue:value forKey:@"gtin"];
    } else if ([key isEqualToString:@"pl-list-prod-note"]) {
        [self setValue:value forKey:@"note"];
    }  else if ([key isEqualToString:@"pl-list-prod-cnt"]) {
        [self setValue:value forKey:@"count"];
    } else if ([key isEqualToString:@"pl-list-prod-prio"]) {
        [self setValue:value forKey:@"prio"];
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

- (NSDictionary *) getDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (gtin != nil) {
        [dict setObject:gtin forKey:@"pl-prod-gtin"];
    }
    if (note != nil) {
        [dict setObject:note forKey:@"pl-list-prod-note"];
    }
    if (count != nil) {
        [dict setObject:count forKey:@"pl-list-prod-cnt"];
    }
    if (prio != nil) {
        [dict setObject:prio forKey:@"pl-list-prod-prio"];
    }
    
    return dict;
}

@end
