//
//  PLYAPIOperation.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

// result block
typedef void(^PLYAPIOperationResult)(id result, NSError *error);


@interface PLYAPIOperation : NSOperation

- (instancetype)initWithEndpointURL:(NSURL *)endpointURL functionPath:(NSString *)functionPath parameters:(NSDictionary *)parameters;

@property (nonatomic, copy) PLYAPIOperationResult resultHandler;

// the verb for the operation, default is GET
@property (nonatomic, copy) NSString *HTTPMethod;

// the payload, will be converted to JSON and sent with content-type 'application/json'
@property (nonatomic, copy) id payload;

@end
