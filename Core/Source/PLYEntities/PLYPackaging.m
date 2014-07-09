//
//  PLYPackaging.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYPackaging.h"

@implementation PLYPackaging

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"pl-prod-pkg-cont"])
	 {
        [self setValue:value forKey:@"contains"];
    }
	 else if ([key isEqualToString:@"pl-prod-pkg-name"])
	 {
        [self setValue:value forKey:@"name"];
    }
	 else if ([key isEqualToString:@"pl-prod-pkg-desc"])
	 {
        [self setValue:value forKey:@"description"];
    }
	 else if ([key isEqualToString:@"pl-prod-pkg-units"])
	 {
        [self setValue:value forKey:@"unit"];
    } 
}

- (NSDictionary *) dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (contains)
	 {
        [dict setObject:contains forKey:@"pl-prod-pkg-cont"];
    }
	
    if (name)
	 {
        [dict setObject:name forKey:@"pl-prod-pkg-name"];
    }
	
    if (description)
	 {
        [dict setObject:description forKey:@"pl-prod-pkg-desc"];
    }
	
    if (unit)
	 {
        [dict setObject:unit forKey:@"pl-prod-pkg-units"];
    }
    
    return dict;
}

@end
