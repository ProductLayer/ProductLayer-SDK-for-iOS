//
//  PLYChatGroup.m
//  ProductLayerSDK
//
//  Created by René Swoboda on 15/06/15.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYChatGroup.h"
#import "PLYUser.h"

@interface PLYChatGroup ()

@end

@implementation PLYChatGroup

+ (NSString *)entityTypeIdentifier
{
    return @"com.productlayer.ChatGroup";
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"pl-chat-title"])
    {
        self.title = value;
    }
    else if ([key isEqualToString:@"pl-chat-members"])
    {
        if ([value isKindOfClass:[NSArray class]]) {
            
            NSMutableArray *myMembers = [NSMutableArray arrayWithCapacity:[(NSArray *)value count]];
            for (id valueMember in value) {
                [myMembers addObject:[[PLYUser alloc] initWithDictionary:valueMember]];
            }
            
            self.members = myMembers;
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [[super dictionaryRepresentation] mutableCopy];
    
    if (_title)
    {
        dict[@"pl-chat-title"] = _title;
    }
    
    if ([_members count])
    {
        NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:1];
        
        for(PLYUser *member in self.members)
        {
            [tmpArray addObject:[member dictionaryRepresentation]];
        }
        
        dict[@"pl-chat-members"] = tmpArray;
    }
    
    // return immutable
    return [dict copy];
}

- (void)updateFromEntity:(PLYChatGroup *)entity
{
    [super updateFromEntity:entity];
    
    self.title = entity.title;
    self.members = entity.members;
}

@end