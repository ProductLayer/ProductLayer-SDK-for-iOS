//
//  PLYAchievement.m
//  ProductLayerSDK
//
//  Created by Oliver Drobnik on 02/11/15.
//  Copyright © 2015 Cocoanetics. All rights reserved.
//

#import "PLYAchievement.h"

@implementation PLYAchievement

+ (NSString *)entityTypeIdentifier
{
    return @"com.productlayer.Achievement";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"pl-achv-name"])
    {
        self.awardName = value;
    }
    else if ([key isEqualToString:@"pl-achv-desc"])
    {
        self.awardDescription = value;
    }
    else if ([key isEqualToString:@"pl-achv-type"])
    {
        self.awardType = value;
    }
    else if ([key isEqualToString:@"pl-achv-img-url"])
    {
        self.imageURL = [NSURL URLWithString:value];
    }
    else if ([key isEqualToString:@"pl-achv-key"])
    {
        self.key = value;
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
    
    if (_awardName)
    {
        dict[@"pl-achv-name"] = _awardName;
    }
    
    if (_awardDescription)
    {
        dict[@"pl-achv-desc"] = _awardDescription;
    }

    if (_awardType)
    {
        dict[@"pl-achv-type"] = _awardType;
    }

    if (_imageURL)
    {
        dict[@"pl-achv-img-url"] = _imageURL;
    }

    if (_key)
    {
        dict[@"pl-achv-key"] = _key;
    }

    // return immutable
    return [dict copy];
}

- (void)updateFromEntity:(PLYAchievement *)entity
{
    [super updateFromEntity:entity];
    
    self.awardName = entity.awardName;
    self.awardDescription = entity.awardDescription;
    self.awardType = entity.awardType;
    self.imageURL = entity.imageURL;
    self.key = entity.key;
}

@end
