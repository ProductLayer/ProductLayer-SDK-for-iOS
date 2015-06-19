//
//  PLYChatMessage.m
//  ProductLayerSDK
//
//  Created by René Swoboda on 15/06/15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYChatMessage.h"

@interface PLYChatMessage ()

@end

@implementation PLYChatMessage

+ (NSString *)entityTypeIdentifier
{
    return @"com.productlayer.ChatMessage";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"pl-chat-message"])
    {
        self.message = value;
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
    
    if (_message)
    {
        dict[@"pl-chat-message"] = _message;
    }
    
    // return immutable
    return [dict copy];
}

- (void)updateFromEntity:(PLYChatMessage *)entity
{
    [super updateFromEntity:entity];
    
    self.message = entity.message;
}

@end