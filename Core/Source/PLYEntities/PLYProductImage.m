//
//  PLYProductImage.m
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "PLYProductImage.h"

#import "PLYAuditor.h"
#import "DTLog.h"
#import "PLYServer.h"

@interface PLYServer (private)
   +(NSString *)_addQueryParameterToUrl:(NSString *)url parameters:(NSDictionary *)parameters;
@end


@implementation PLYProductImage
{
   
   // The class identifier.
   NSString *Class;
   // The object id.
   NSString *Id;
   // The version.
   NSNumber *version;
   
   // The user who created the object.
   PLYAuditor *createdBy;
   // The timestamp when object was created.
   NSNumber *createdTime;
   
   // The user who updated the object the last time.
   PLYAuditor *updatedBy;
   // The timestamp when object was updated the last time.
   NSNumber *updatedTime;
   
   // The name of the image.
   NSString *name;
   // The gtin (barcode) of the product.
   NSString *gtin;
   
   // The image file id.
   NSString *fileId;
   
   // The height in pixel of the image.
   NSNumber *height;
   // The width in pixel of the image.
   NSNumber *width;
   
   // The url of the image.
   NSString *url;
   // The voting score of the image. (+1 for a up vote, -1 for a down vote)
   NSNumber *votingScore;
   // The users who up voted image.
   NSMutableArray *upVoters;
   // The users who down voted image.
   NSMutableArray *downVoters;
}

@synthesize createdBy;
@synthesize createdTime;
@synthesize Id;
@synthesize Class;
@synthesize fileId;
@synthesize height;
@synthesize name;
@synthesize url;
@synthesize votingScore;
@synthesize width;
@synthesize gtin;
@synthesize updatedBy;
@synthesize updatedTime;
@synthesize version;
@synthesize upVoters;
@synthesize downVoters;

+ (NSString *) classIdentifier{
    return @"com.productlayer.core.domain.beans.ProductImage";
}

+ (PLYProductImage *)instanceFromDictionary:(NSDictionary *)aDictionary {
    
    NSString *class = [aDictionary objectForKey:@"pl-class"];
    
    // Check if class identifier is valid for parsing.
    if(class != nil && [class isEqualToString: [PLYProductImage classIdentifier]]){
        PLYProductImage *instance = [[PLYProductImage alloc] init];
        [instance setAttributesFromDictionary:aDictionary];
        return instance;
    }
    
    DTLogError(@"No valid classIdentifier found for PLYProductImage in dictionary: %@", aDictionary);
    
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

    } else if ([key isEqualToString:@"pl-upd-by"]) {

        if ([value isKindOfClass:[NSDictionary class]]) {
            self.updatedBy = [PLYAuditor instanceFromDictionary:value];
        }

    } else if ([key isEqualToString:@"pl-img-usr_upvotes"]) {
        self.upVoters = [NSMutableArray arrayWithCapacity:1];
        if ([value isKindOfClass:[NSArray class]]) {
            for(NSDictionary *user in value){
                [self.upVoters addObject:[PLYAuditor instanceFromDictionary:user]];
            }
        }
        
    } else if ([key isEqualToString:@"pl-img-usr_downvotes"]) {
        self.downVoters = [NSMutableArray arrayWithCapacity:1];
        if ([value isKindOfClass:[NSArray class]]) {
            for(NSDictionary *user in value){
                [self.downVoters addObject:[PLYAuditor instanceFromDictionary:user]];
            }
        }
    } else {
        [super setValue:value forKey:key];
    }

}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {

    if ([key isEqualToString:@"pl-id"]) {
        [self setValue:value forKey:@"Id"];
    } else if ([key isEqualToString:@"pl-version"]) {
        [self setValue:value forKey:@"version"];
    } else if ([key isEqualToString:@"pl-class"]) {
        [self setValue:value forKey:@"Class"];
    } else if ([key isEqualToString:@"pl-created-by"]) {
        [self setValue:value forKey:@"createdBy"];
    } else if ([key isEqualToString:@"pl-created-time"]) {
        [self setValue:value forKey:@"createdTime"];
    } else if ([key isEqualToString:@"pl-upd-by"]) {
        [self setValue:value forKey:@"udpatedBy"];
    } else if ([key isEqualToString:@"pl-upd-time"]) {
        [self setValue:value forKey:@"updatedTime"];
    } else if ([key isEqualToString:@"pl-img-file_id"]) {
        [self setValue:value forKey:@"fileId"];
    } else if ([key isEqualToString:@"pl-img-h-px"]) {
        [self setValue:value forKey:@"height"];
    } else if ([key isEqualToString:@"pl-img-name"]) {
        [self setValue:value forKey:@"name"];
    } else if ([key isEqualToString:@"pl-img-url"]) {
        [self setValue:value forKey:@"url"];
    } else if ([key isEqualToString:@"pl-img-vote_score"]) {
        [self setValue:value forKey:@"votingScore"];
    } else if ([key isEqualToString:@"pl-img-w-px"]) {
        [self setValue:value forKey:@"width"];
    } else if ([key isEqualToString:@"pl-prod-gtin"]) {
        [self setValue:value forKey:@"gtin"];
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
    if (fileId != nil) {
        [dict setObject:fileId forKey:@"pl-img-file_id"];
    }
    if (height != nil) {
        [dict setObject:height forKey:@"pl-img-h-px"];
    }
    if (name != nil) {
        [dict setObject:name forKey:@"pl-img-name"];
    }
    if (url != nil) {
        [dict setObject:url forKey:@"pl-img-url"];
    }
    if (votingScore != nil) {
        [dict setObject:votingScore forKey:@"pl-img-vote_score"];
    }
    if (width != nil) {
        [dict setObject:width forKey:@"pl-img-w-px"];
    }
    if (gtin != nil) {
        [dict setObject:gtin forKey:@"pl-prod-gtin"];
    }
    
    if(upVoters != nil && [upVoters count] > 0){
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[upVoters count]];
        for(PLYAuditor *user in upVoters){
            [tmpArray addObject:[user getDictionary]];
        }
        
        [dict setObject:tmpArray forKey:@"pl-img-usr_upvotes"];
    }
    
    if(downVoters != nil && [downVoters count] > 0){
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[downVoters count]];
        for(PLYAuditor *user in downVoters){
            [tmpArray addObject:[user getDictionary]];
        }
        
        [dict setObject:tmpArray forKey:@"pl-img-usr_downvotes"];
    }
    
    return dict;
}

- (NSString *)getUrlForWidth:(CGFloat)maxWidth andHeight:(CGFloat)maxHeight crop:(BOOL)crop{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (maxWidth>0)
    {
        [parameters setObject:[NSString stringWithFormat:@"%lu",(unsigned long)maxWidth] forKey:@"max_width"];
    }
    
    if (maxHeight>0)
    {
        [parameters setObject:[NSString stringWithFormat:@"%lu",(unsigned long)maxHeight] forKey:@"max_height"];
    }
    
    if (crop)
    {
        [parameters setObject:@"true" forKey:@"crop"];
    }
    
    if(url) {
        NSString *path = [PLYServer _addQueryParameterToUrl:url parameters:parameters];
        return path;
    }
    
    return nil;
}

@end
