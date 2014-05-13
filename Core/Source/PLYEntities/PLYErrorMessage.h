//
//  PLYErrorMessage.h
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The error message with all needed information.
 **/
@interface PLYErrorMessage : NSObject {
    // The error message.
    NSString *message;
    // The productlayer error code.
    NSNumber *code;
    // The stacktrace will only be available for alpha and beta api's.
    NSString *throwable;
}

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSNumber *code;
@property (nonatomic, copy) NSString *throwable;

+ (PLYErrorMessage *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;

@end
