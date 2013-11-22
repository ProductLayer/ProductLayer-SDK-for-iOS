//
//  PLYAPIOperation.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

// result block
typedef void(^PLYAPIOperationResult)(NSDictionary *dictionary, NSError *error);


@interface PLYAPIOperation : NSOperation

- (instancetype)initWithEndpointURL:(NSURL *)endpointURL functionPath:(NSString *)functionPath parameters:(NSDictionary *)parameters;

@end
