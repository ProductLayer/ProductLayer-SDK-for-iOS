//
//  PLYServer.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYAPIOperation.h"

@class PLYUser;
@class PLYList;
@class PLYListItem;

@interface PLYServer : NSObject

+ (id)sharedPLYServer;

/**
 @name Search
 */

// searches for a GTIN
- (void)performSearchForGTIN:(NSString *)gtin
                    language:(NSString *)language
                  completion:(PLYAPIOperationResult)completion;

// searches for a product name
- (void)performSearchForName:(NSString *)name
                    language:(NSString *)language
                  completion:(PLYAPIOperationResult)completion;


/**
 @name Products
 */
- (void) getImagesForGTIN:(NSString *)gtin
               completion:(PLYAPIOperationResult)completion;

- (void) getLastUploadedImagesWithPage:(int)page
                                andRPP:(int)rpp
                            completion:(PLYAPIOperationResult)completion;

- (void) getCategoriesForLocale:(NSString *)language
                     completion:(PLYAPIOperationResult)completion;

/**
 @name Managing Users
 */

// creates a new user account
- (void)createUserWithUser:(NSString *)user
                     email:(NSString *)email
                  password:(NSString *)password
                completion:(PLYAPIOperationResult)completion;

// login
- (void)loginWithUser:(NSString *)user
             password:(NSString *)password
           completion:(PLYAPIOperationResult)completion;

// logout
- (void)logoutUserWithCompletion:(PLYAPIOperationResult)completion;

// name of the currently logged in use or `nil` if not logged in
@property (nonatomic, readonly) PLYUser *loggedInUser;


/**
 @name Managing Products
 */

// create

- (void)createProductWithGTIN:(NSString *)gtin
                   dictionary:(NSDictionary *)dictionary
                   completion:(PLYAPIOperationResult)completion;

- (void)updateProductWithGTIN:(NSString *)gtin
                   dictionary:(NSDictionary *)dictionary
                   completion:(PLYAPIOperationResult)completion;

/**
 @name Image Handling
 */

- (void)uploadImageData:(UIImage *)data
                forGTIN:(NSString *)gtin
             completion:(PLYAPIOperationResult)completion;

- (void) upVoteImageWithId:(NSString *)imageFileId
                   andGTIN:(NSString *)gtin
                completion:(PLYAPIOperationResult)completion;

- (void) downVoteImageWithId:(NSString *)imageFileId
                     andGTIN:(NSString *)gtin
                  completion:(PLYAPIOperationResult)completion;

/**
 @name File Handling
 */
- (void)uploadFileData:(NSData *)data
               forGTIN:(NSString *)gtin
            completion:(PLYAPIOperationResult)completion;


/**
 Construct fully qualified image URL for a product image
 */
- (NSURL *)imageURLForProductGTIN:(NSString *)gtin
                  imageIdentifier:(NSString *)imageIdentifier
                         maxWidth:(CGFloat)maxWidth
                        maxHeight:(CGFloat)maxHeight
                             crop:(BOOL)crop __attribute__ ((deprecated));

/**
 @name Reviews
 */
// Search for reviews
- (void) performSearchForReviewWithGTIN:(NSString *)gtin
                           withLanguage:(NSString *)language
                   fromUserWithNickname:(NSString *)nickname
                             withRating:(NSNumber *)rating
                                orderBy:(NSString *)orderBy
                                   page:(NSNumber *)page
                         recordsPerPage:(NSNumber *)rpp
                             completion:(PLYAPIOperationResult)completion;

// Create a review for a product.
- (void) createReviewForGTIN:(NSString *)gtin
                  dictionary:(NSDictionary *)dictionary
                  completion:(PLYAPIOperationResult)completion;
/**
 @name Lists
 */
- (void) createProductList:(PLYList *)list
                completion:(PLYAPIOperationResult)completion;

- (void) performSearchForProductListFromUser:(PLYUser *)user
                                 andListType:(NSString *)listType
                                        page:(NSNumber *)page
                              recordsPerPage:(NSNumber *)rpp
                                  completion:(PLYAPIOperationResult)completion;

- (void) getProductListWithId:(NSString *)listId
                   completion:(PLYAPIOperationResult)completion;

- (void) updateProductList:(PLYList *)list
                completion:(PLYAPIOperationResult)completion;

- (void) deleteProductListWithId:(NSString *)listId
                      completion:(PLYAPIOperationResult)completion;

/**
 * Add/Remove list items
 **/
- (void) addOrReplaceListItem:(PLYListItem *)listItem
                 toListWithId:(NSString *)listId
                   completion:(PLYAPIOperationResult)completion;

- (void) deleteProductWithgGTIN:(NSString *)gtin
                 fromListWithId:(NSString *)listId
                     completion:(PLYAPIOperationResult)completion;

/**
 * List sharing
 **/
- (void) shareProductListWithId:(NSString *)listId
                     withUserId:(NSString *)userId
                     completion:(PLYAPIOperationResult)completion;

- (void) unshareProductListWithId:(NSString *)listId
                       withUserId:(NSString *)userId
                       completion:(PLYAPIOperationResult)completion;

/**
 @name Users
 */
- (void) performUserSearch:(NSString *)searchText
                completion:(PLYAPIOperationResult)completion;

- (void)  getUserByNickname:(NSString *)nickname
                 completion:(PLYAPIOperationResult)completion;

- (void) getAvatarImageUrlFromUser:(PLYUser *)user
                        completion:(PLYAPIOperationResult)completion;

- (void) getFollowerFromUser:(NSString *)nickname
                        page:(NSNumber *)page
              recordsPerPage:(NSNumber *)rpp
                  completion:(PLYAPIOperationResult)completion;

- (void) getFollowingFromUser:(NSString *)nickname
                         page:(NSNumber *)page
               recordsPerPage:(NSNumber *)rpp
                   completion:(PLYAPIOperationResult)completion;

- (void) followUserWithNickname:(NSString *)nickname
                     completion:(PLYAPIOperationResult)completion;

- (void) unfollowUserWithNickname:(NSString *)nickname
                       completion:(PLYAPIOperationResult)completion;




+ (NSString *)_functionPathForFunction:(NSString *)function
                            parameters:(NSDictionary *)parameters;

+ (NSString *)_addQueryParameterToUrl:(NSString *)url
                           parameters:(NSDictionary *)parameters;
@end
