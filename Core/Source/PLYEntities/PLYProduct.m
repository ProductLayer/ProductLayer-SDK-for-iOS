//
//  PLYProduct.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYProduct.h"

#import "PLYAuditor.h"
#import "PLYPackaging.h"
#import "DTLog.h"

@implementation PLYProduct

@synthesize Class;
@synthesize Id;
@synthesize brandName;
@synthesize brandOwner;
@synthesize createdBy;
@synthesize createdTime;
@synthesize language;
@synthesize category;
@synthesize longDescription;
@synthesize shortDescription;
@synthesize gtin;
@synthesize homepage;
@synthesize links;
@synthesize name;
@synthesize packaging;
@synthesize rating;
@synthesize updatedBy;
@synthesize updatedTime;
@synthesize version;
@synthesize characteristics;
@synthesize nutritious;

+ (NSString *)entityTypeIdentifier
{
    return @"com.productlayer.Product";
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	
	if (self)
	{
		[self setAttributesFromDictionary:dictionary];
	}
	
	return self;
}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary {

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [self setValuesForKeysWithDictionary:aDictionary];

}

- (void)setValue:(id)value forKey:(NSString *)key {

    if ([key isEqualToString:@"pl-created-by"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.createdBy = [[PLYAuditor alloc] initWithDictionary:value];
        }

    } else if ([key isEqualToString:@"pl-prod-lnks"]) {

        if ([value isKindOfClass:[NSArray class]]) {

            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }

            self.links = myMembers;

        }

    } else if ([key isEqualToString:@"pl-prod-pkg"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.packaging = [[PLYPackaging alloc] initWithDictionary:value];
        }

    } else if ([key isEqualToString:@"pl-upd-by"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.updatedBy = [[PLYAuditor alloc] initWithDictionary:value];
        }

    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"pl-class"]) {
        [self setValue:value forKey:@"Class"];
    } else if ([key isEqualToString:@"pl-id"]) {
        [self setValue:value forKey:@"Id"];
    } else if ([key isEqualToString:@"pl-brand-name"]) {
        [self setValue:value forKey:@"brandName"];
    } else if ([key isEqualToString:@"pl-brand-own-name"]) {
        [self setValue:value forKey:@"brandOwner"];
    } else if ([key isEqualToString:@"pl-created-by"]) {
        [self setValue:value forKey:@"createdBy"];
    } else if ([key isEqualToString:@"pl-created-time"]) {
        [self setValue:value forKey:@"createdTime"];
    } else if ([key isEqualToString:@"pl-lng"]) {
        [self setValue:value forKey:@"language"];
    } else if ([key isEqualToString:@"pl-prod-cat"]) {
        [self setValue:value forKey:@"category"];
    } else if ([key isEqualToString:@"pl-prod-desc-long"]) {
        [self setValue:value forKey:@"longDescription"];
    } else if ([key isEqualToString:@"pl-prod-desc-short"]) {
        [self setValue:value forKey:@"shortDescription"];
    } else if ([key isEqualToString:@"pl-prod-gtin"]) {
        [self setValue:value forKey:@"gtin"];
    } else if ([key isEqualToString:@"pl-prod-homepage"]) {
        [self setValue:value forKey:@"homepage"];
    } else if ([key isEqualToString:@"pl-prod-lnks"]) {
        [self setValue:value forKey:@"links"];
    } else if ([key isEqualToString:@"pl-prod-name"]) {
        [self setValue:value forKey:@"name"];
    } else if ([key isEqualToString:@"pl-prod-pkg"]) {
        [self setValue:value forKey:@"packaging"];
    } else if ([key isEqualToString:@"pl-prod-rating"]) {
        [self setValue:value forKey:@"rating"];
    } else if ([key isEqualToString:@"pl-upd-by"]) {
        [self setValue:value forKey:@"updatedBy"];
    } else if ([key isEqualToString:@"pl-upd-time"]) {
        [self setValue:value forKey:@"updatedTime"];
    } else if ([key isEqualToString:@"pl-prod-char"]) {
        [self setValue:value forKey:@"characteristics"];
    } else if ([key isEqualToString:@"pl-prod-nutr"]) {
        [self setValue:value forKey:@"nutritious"];
    } else if ([key isEqualToString:@"pl-version"]) {
        [self setValue:value forKey:@"version"];
    }
}

- (NSDictionary *) dictionaryRepresentation{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (Class != nil) {
        [dict setObject:Class forKey:@"pl-class"];
    }
    if (Id != nil) {
        [dict setObject:Id forKey:@"pl-id"];
    }
    if (brandName != nil) {
        [dict setObject:brandName forKey:@"pl-brand-name"];
    }
    if (brandOwner != nil) {
        [dict setObject:brandOwner forKey:@"pl-brand-own-name"];
    }
    if (createdBy != nil) {
        [dict setObject:[createdBy dictionaryRepresentation] forKey:@"pl-created-by"];
    }
    if (createdTime != nil) {
        [dict setObject:createdTime forKey:@"pl-created-time"];
    }
    if (language != nil) {
        [dict setObject:language forKey:@"pl-lng"];
    }
    if (category != nil) {
        [dict setObject:category forKey:@"pl-prod-cat"];
    }
    if (longDescription != nil) {
        [dict setObject:longDescription forKey:@"pl-prod-desc-long"];
    }
    if (shortDescription != nil) {
        [dict setObject:shortDescription forKey:@"pl-prod-desc-short"];
    }
    if (gtin != nil) {
        [dict setObject:gtin forKey:@"pl-prod-gtin"];
    }
    if (homepage != nil) {
        [dict setObject:homepage forKey:@"pl-prod-homepage"];
    }
    if (links != nil) {
        [dict setObject:links forKey:@"pl-prod-lnks"];
    }
    if (name != nil) {
        [dict setObject:name forKey:@"pl-prod-name"];
    }
    if (packaging != nil) {
        [dict setObject:[packaging dictionaryRepresentation] forKey:@"pl-prod-pkg"];
    }
    if (rating != nil) {
        [dict setObject:rating forKey:@"pl-prod-rating"];
    }
    if (updatedBy != nil) {
        [dict setObject:[updatedBy dictionaryRepresentation] forKey:@"pl-upd-by"];
    }
    if (updatedTime != nil) {
        [dict setObject:updatedTime forKey:@"pl-upd-time"];
    }
    if (characteristics != nil) {
        [dict setObject:characteristics forKey:@"pl-prod-char"];
    }
    if (nutritious != nil) {
        [dict setObject:nutritious forKey:@"pl-prod-nutr"];
    }
    if (version != nil) {
        [dict setObject:version forKey:@"pl-version"];
    }
    
    return dict;
}



@end
