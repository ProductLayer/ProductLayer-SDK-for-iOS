//
//  PLYListItem.m
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYListItem.h"

#import "DTLog.h"

@implementation PLYListItem

@synthesize Id;
@synthesize gtin;
@synthesize note;
@synthesize qty;
@synthesize prio;

+ (NSString *) classIdentifier{
    return @"com.productlayer.ProductListItem";
}

+ (PLYListItem *)instanceFromDictionary:(NSDictionary *)aDictionary {
    PLYListItem *instance = [[PLYListItem alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;
}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {
    
    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    [self setValuesForKeysWithDictionary:aDictionary];
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if ([key isEqualToString:@"pl-id"]) {
        [self setValue:value forKey:@"Id"];
    } else if ([key isEqualToString:@"pl-prod-gtin"]) {
        [self setValue:value forKey:@"gtin"];
    } else if ([key isEqualToString:@"pl-list-prod-note"]) {
        [self setValue:value forKey:@"note"];
    }  else if ([key isEqualToString:@"pl-list-prod-cnt"]) {
        [self setValue:value forKey:@"qty"];
    } else if ([key isEqualToString:@"pl-list-prod-prio"]) {
        [self setValue:value forKey:@"prio"];
    }
}

- (NSDictionary *) getDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if(Id){
        [dict setObject:Id forKey:@"pl-id"];
    }
    
    if (gtin != nil) {
        [dict setObject:gtin forKey:@"pl-prod-gtin"];
    }
    if (note != nil) {
        [dict setObject:note forKey:@"pl-list-prod-note"];
    }
    if (qty != nil) {
        [dict setObject:qty forKey:@"pl-list-prod-cnt"];
    }
    if (prio != nil) {
        [dict setObject:prio forKey:@"pl-list-prod-prio"];
    }
    
    return dict;
}

@end
