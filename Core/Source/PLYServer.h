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

/**
 @name Search
 */

// searches for a GTIN
- (void)performSearchForGTIN:(NSString *)gtin language:(NSString *)language completion:(PLYAPIOperationResult)completion;

// searches for a product name
- (void)performSearchForName:(NSString *)name language:(NSString *)language completion:(PLYAPIOperationResult)completion;


/**
 @name Products
 */
- (void)getImagesForGTIN:(NSString *)gtin completion:(PLYAPIOperationResult)completion;

/**
 @name Managing Users
 */

// creates a new user account
- (void)createUserWithUser:(NSString *)user email:(NSString *)email password:(NSString *)password completion:(PLYAPIOperationResult)completion;

// login
- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(PLYAPIOperationResult)completion;

// logout
- (void)logoutUserWithCompletion:(PLYAPIOperationResult)completion;

// name of the currently logged in use or `nil` if not logged in
@property (nonatomic, readonly) NSString *loggedInUser;


/**
 @name Managing Products
 */

// create

- (void)createProductWithGTIN:(NSString *)gtin dictionary:(NSDictionary *)dictionary completion:(PLYAPIOperationResult)completion;

/**
 @name Image Handling
 */

- (void)uploadImageData:(UIImage *)data forGTIN:(NSString *)gtin completion:(PLYAPIOperationResult)completion;

/**
 @name File Handling
 */
- (void)uploadFileData:(NSData *)data forGTIN:(NSString *)gtin completion:(PLYAPIOperationResult)completion;


/**
 Construct fully qualified image URL for a product image
 */
- (NSURL *)imageURLForProductGTIN:(NSString *)gtin imageIdentifier:(NSString *)imageIdentifier maxWidth:(CGFloat)maxWidth;

@end
