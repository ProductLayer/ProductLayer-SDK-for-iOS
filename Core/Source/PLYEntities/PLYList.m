//
//  PLYList.m
//  PL
//
//  Created by René Swoboda on 29/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYList.h"

#import "DTLog.h"

#import "PLYListItem.h"
#import "PLYAuditor.h"

@implementation PLYList

@synthesize Class;
@synthesize Id;
@synthesize version;

@synthesize createdBy;
@synthesize createdTime;
@synthesize updatedBy;
@synthesize updatedTime;

@synthesize title;
@synthesize description;
@synthesize listType;

@synthesize shareType;
@synthesize sharedUsers;

@synthesize listItems;

+ (NSString *) classIdentifier{
    return @"com.productlayer.core.domain.beans.lists.ProductList";
}

+ (PLYList *)instanceFromDictionary:(NSDictionary *)aDictionary {
    
    NSString *class = [aDictionary objectForKey:@"pl-class"];
    
    // Check if class identifier is valid for parsing.
    if(class != nil && [class isEqualToString: [PLYList classIdentifier]]){
        PLYList *instance = [[PLYList alloc] init];
        [instance setAttributesFromDictionary:aDictionary];
        return instance;
    }
    
    DTLogError(@"No valid classIdentifier found for PLYList in dictionary: %@", aDictionary);
    
    return nil;
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
            self.createdBy = [PLYAuditor instanceFromDictionary:value];
        }
        
    } else if ([key isEqualToString:@"pl-list-products"]) {
        
        if ([value isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
            for (id valueMember in value) {
                [myMembers addObject:[PLYListItem instanceFromDictionary:valueMember]];
            }
            
            self.listItems = myMembers;
        }
        
    } else if ([key isEqualToString:@"pl-upd-by"]) {
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.updatedBy = [PLYAuditor instanceFromDictionary:value];
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
    }  else if ([key isEqualToString:@"pl-version"]) {
        [self setValue:value forKey:@"version"];
    } else if ([key isEqualToString:@"pl-created-by"]) {
        [self setValue:value forKey:@"createdBy"];
    } else if ([key isEqualToString:@"pl-created-time"]) {
        [self setValue:value forKey:@"createdTime"];
    } else if ([key isEqualToString:@"pl-upd-by"]) {
        [self setValue:value forKey:@"updatedBy"];
    } else if ([key isEqualToString:@"pl-upd-time"]) {
        [self setValue:value forKey:@"updatedTime"];
    }
    
    else if ([key isEqualToString:@"pl-list-title"]) {
        [self setValue:value forKey:@"title"];
    } else if ([key isEqualToString:@"pl-list-desc"]) {
        [self setValue:value forKey:@"description"];
    }  else if ([key isEqualToString:@"pl-list-type"]) {
        [self setValue:value forKey:@"listType"];
    } else if ([key isEqualToString:@"pl-list-share"]) {
        [self setValue:value forKey:@"shareType"];
    } else if ([key isEqualToString:@"pl-list-shared-users"]) {
        [self setValue:value forKey:@"sharedUsers"];
    }
}

- (NSDictionary *) getDictionary{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if (Class != nil) {
        [dict setObject:Class forKey:@"pl-class"];
    }
    if (Id != nil) {
        [dict setObject:Id forKey:@"pl-id"];
    }
    if (version != nil) {
        [dict setObject:version forKey:@"pl-version"];
    }
    if (createdBy != nil) {
        [dict setObject:[createdBy getDictionary] forKey:@"pl-created-by"];
    }
    if (createdTime != nil) {
        [dict setObject:createdTime forKey:@"pl-created-time"];
    }
    if (updatedBy != nil) {
        [dict setObject:[updatedBy getDictionary] forKey:@"pl-upd-by"];
    }
    if (updatedTime != nil) {
        [dict setObject:updatedTime forKey:@"pl-upd-time"];
    }
    
    if (title != nil) {
        [dict setObject:title forKey:@"pl-list-title"];
    }
    if (description != nil) {
        [dict setObject:description forKey:@"pl-list-desc"];
    }
    if (listType != nil) {
        [dict setObject:listType forKey:@"pl-list-type"];
    }
    if (shareType != nil) {
        [dict setObject:shareType forKey:@"pl-list-share"];
    }
    if (sharedUsers != nil) {
        [dict setObject:sharedUsers forKey:@"pl-list-shared-users"];
    }
    
    if (listItems != nil) {
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:1];
        
        for(PLYListItem *item in listItems){
            [tmpArray addObject:[item getDictionary]];
        }
        [dict setObject:tmpArray forKey:@"pl-list-products"];
    }
    
    return dict;
}

/**
 * Simple check if the product list can be send to the server for saving.
 **/
- (BOOL) isValidForSaving{
    if([title length] > 5 && [listType length] && [shareType length]){
        return true;
    }
    
    return false;
}

+ (NSArray *) availableListTypes{
    NSMutableArray *listTypes = [NSMutableArray arrayWithObjects:@"pl-list-type-wish",
                               @"pl-list-type-shopping",
                               @"pl-list-type-borrowed",
                               @"pl-list-type-owned",
                               @"pl-list-type-other", nil];
    
    return listTypes;
}

+ (NSArray *) availableSharingTypes{
    NSMutableArray *sharingTypes = [NSMutableArray arrayWithObjects:@"pl-list-share-public",
                                 @"pl-list-share-friends",
                                 @"pl-list-share-specific",
                                 @"pl-list-share-none", nil];
    
    return sharingTypes;
}


@end
