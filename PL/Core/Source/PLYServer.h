//
//  PLYServer.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYAPIOperation.h"

@interface PLYServer : NSObject

- (instancetype)initWithHostURL:(NSURL *)hostURL;

// searches for a GTIN
- (void)performSearchForGTIN:(NSString *)gtin language:(NSString *)language completion:(PLYAPIOperationResult)completion;


@end
