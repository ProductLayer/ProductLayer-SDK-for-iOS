#import "PLYProductImage.h"

#import "PLYAuditor.h"
#import "DTLog.h"
#import "PLYServer.h"

@implementation PLYProductImage

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
    }   else {
        [super setValue:value forUndefinedKey:key];
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
