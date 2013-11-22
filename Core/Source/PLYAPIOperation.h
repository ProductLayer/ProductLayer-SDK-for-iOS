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

@class PLYAPIOperation;

@protocol PLYAPIOperationDelegate <NSObject>

@optional
// called a the begin of main when the execution of the operation is about to start
- (void)operationWillExecute:(PLYAPIOperation *)operation;

// called if an successful operation received an access token
- (void)operation:(PLYAPIOperation *)operation didReceiveAccessToken:(NSString *)token;

// called at the end of main when the execution of the operation has finished or failed
- (void)operation:(PLYAPIOperation *)operation didExecuteWithError:(NSError *)error;

@end



@interface PLYAPIOperation : NSOperation

// creates an operation, endpoing URL and function path are mandatory
- (instancetype)initWithEndpointURL:(NSURL *)endpointURL functionPath:(NSString *)functionPath parameters:(NSDictionary *)parameters;

// optional handler for the result
@property (nonatomic, copy) PLYAPIOperationResult resultHandler;

// the verb for the operation, default is GET
@property (nonatomic, copy) NSString *HTTPMethod;

// the payload, will be converted to JSON and sent with content-type 'application/json'
@property (nonatomic, copy) id payload;

// delegate to inform about starting and ending of operation
@property (nonatomic, weak) id <PLYAPIOperationDelegate> delegate;

// an authorization token for operations requiring it
@property (nonatomic, copy) NSString *accessToken;

@end
