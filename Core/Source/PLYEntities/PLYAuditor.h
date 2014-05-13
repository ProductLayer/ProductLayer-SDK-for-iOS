//
//  PLYAuditor.h
//  PL
//
//  Created by René Swoboda on 25/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLYAuditor : NSObject {

    // The id of the user who created/updated the object
    NSString *userId;
    
    // The id of the application the object was created/updated with.
    NSString *appId;
    
    // The nickname of the user
    NSString *userNickname;

}

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *userNickname;

+ (PLYAuditor *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSDictionary *) getDictionary;

@end
