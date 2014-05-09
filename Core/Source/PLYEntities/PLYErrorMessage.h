//
//  PLYErrorMessage.h
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLYErrorMessage : NSObject {
    NSString *message;
    NSNumber *code;
    NSString *throwable;
}

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, copy) NSString *throwable;

+ (PLYErrorMessage *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
