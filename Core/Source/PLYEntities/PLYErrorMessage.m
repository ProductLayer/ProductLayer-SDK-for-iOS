//
//  PLYErrorMessage.m
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYErrorMessage.h"

@implementation PLYErrorMessage

@synthesize message;
@synthesize code;
@synthesize throwable;

+ (PLYErrorMessage *)instanceFromDictionary:(NSDictionary *)aDictionary {
    
    PLYErrorMessage *instance = [[PLYErrorMessage alloc] init];
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
    if ([key isEqualToString:@"message"]) {
        [self setValue:value forKey:@"message"];
    } else if ([key isEqualToString:@"code"]) {
        [self setValue:value forKey:@"code"];
    } else if ([key isEqualToString:@"throwable"]) {
        [self setValue:value forKey:@"throwable"];
    }
}


@end
