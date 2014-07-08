//
//  PLYReview.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYReview.h"

#import "PLYAuditor.h"
#import "PLYPackaging.h"
#import "DTLog.h"

@implementation PLYReview

@synthesize Class;
@synthesize Id;
@synthesize version;

@synthesize createdBy;
@synthesize createdTime;
@synthesize updatedBy;
@synthesize updatedTime;

@synthesize gtin;
@synthesize subject;
@synthesize body;
@synthesize rating;
@synthesize language;

@synthesize votingScore;
@synthesize upVoter;
@synthesize downVoter;

+ (NSString *) classIdentifier{
    return @"com.productlayer.Review";
}

+ (PLYReview *)instanceFromDictionary:(NSDictionary *)aDictionary {
    
    NSString *class = [aDictionary objectForKey:@"pl-class"];
    
    // Check if class identifier is valid for parsing.
    if(class != nil && [class isEqualToString: [PLYReview classIdentifier]]){
        PLYReview *instance = [[PLYReview alloc] init];
        [instance setAttributesFromDictionary:aDictionary];
        return instance;
    }
    
    DTLogError(@"No valid classIdentifier found for PLYReview in dictionary: %@", aDictionary);
    
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
        
    } else if ([key isEqualToString:@"pl-rev-usr_upvotes"]) {
        
        if ([value isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }
            
            self.upVoter = myMembers;
            
        }
        
    } else if ([key isEqualToString:@"pl-rev-usr_downvotes"]) {
        
        if ([value isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[value count]];
            for (id valueMember in value) {
                [myMembers addObject:valueMember];
            }
            
            self.downVoter = myMembers;
            
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
    
    else if ([key isEqualToString:@"pl-prod-gtin"]) {
        [self setValue:value forKey:@"gtin"];
    } else if ([key isEqualToString:@"pl-rev-subj"]) {
        [self setValue:value forKey:@"subject"];
    }  else if ([key isEqualToString:@"pl-rev-body"]) {
        [self setValue:value forKey:@"body"];
    } else if ([key isEqualToString:@"pl-rev-rating"]) {
        [self setValue:value forKey:@"rating"];
    } else if ([key isEqualToString:@"pl-lng"]) {
        [self setValue:value forKey:@"language"];
    }
    
    else if ([key isEqualToString:@"pl-rev-votes"]) {
        [self setValue:value forKey:@"votingScore"];
    } else if ([key isEqualToString:@"pl-rev-usr_upvotes"]) {
        [self setValue:value forKey:@"upVoter"];
    } else if ([key isEqualToString:@"pl-rev-usr_downvotes"]) {
        [self setValue:value forKey:@"downVoter"];
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
    
    if (gtin != nil) {
        [dict setObject:gtin forKey:@"pl-prod-gtin"];
    }
    if (subject != nil) {
        [dict setObject:subject forKey:@"pl-rev-subj"];
    }
    if (body != nil) {
        [dict setObject:body forKey:@"pl-rev-body"];
    }
    if (rating != nil) {
        [dict setObject:rating forKey:@"pl-rev-rating"];
    }
    if (language != nil) {
        [dict setObject:language forKey:@"pl-lng"];
    }
    
    if (votingScore != nil) {
        [dict setObject:votingScore forKey:@"pl-rev-votes"];
    }
    if (upVoter != nil) {
        [dict setObject:upVoter forKey:@"pl-rev-usr_upvotes"];
    }
    if (downVoter != nil) {
        [dict setObject:downVoter forKey:@"pl-rev-usr_downvotes"];
    }
    
    return dict;
}



@end

