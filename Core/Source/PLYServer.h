//
//  PLYServer.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//


/*
 Completion handler for Discogs API calls
 */
typedef void (^PLYCompletion)(id result, NSError *error);

@class PLYUser;
@class PLYList;
@class PLYListItem;

@interface PLYServer : NSObject

+ (id)sharedPLYServer;
- (NSURLSession *)session;

/**
 @name Search
 */

// searches for a GTIN
- (void)performSearchForGTIN:(NSString *)gtin
                    language:(NSString *)language
                  completion:(PLYCompletion)completion;

// searches for a product name
- (void)performSearchForName:(NSString *)name
                    language:(NSString *)language
                  completion:(PLYCompletion)completion;


/**
 @name Products
 */
- (void) getImagesForGTIN:(NSString *)gtin
               completion:(PLYCompletion)completion;

- (void) getLastUploadedImagesWithPage:(int)page
                                andRPP:(int)rpp
                            completion:(PLYCompletion)completion;

- (void) getCategoriesForLocale:(NSString *)language
                     completion:(PLYCompletion)completion;

/**
 @name Managing Users
 */

// creates a new user account
- (void)createUserWithName:(NSString *)user
                     email:(NSString *)email
                completion:(PLYCompletion)completion;

// login
- (void)loginWithUser:(NSString *)user
             password:(NSString *)password
           completion:(PLYCompletion)completion;

// logout
- (void)logoutUserWithCompletion:(PLYCompletion)completion;

// Request new password
- (void)requestNewPasswordForUserWithEmail:(NSString *)email
                                completion:(PLYCompletion)completion;

// name of the currently logged in use or `nil` if not logged in
@property (nonatomic, readonly) PLYUser *loggedInUser;


/**
 @name Managing Products
 */

// create

- (void)createProductWithGTIN:(NSString *)gtin
                   dictionary:(NSDictionary *)dictionary
                   completion:(PLYCompletion)completion;

- (void)updateProductWithGTIN:(NSString *)gtin
                   dictionary:(NSDictionary *)dictionary
                   completion:(PLYCompletion)completion;

/**
 @name Image Handling
 */

- (void)uploadImageData:(UIImage *)data
                forGTIN:(NSString *)gtin
             completion:(PLYCompletion)completion;

- (void) upVoteImageWithId:(NSString *)imageFileId
                   andGTIN:(NSString *)gtin
                completion:(PLYCompletion)completion;

- (void) downVoteImageWithId:(NSString *)imageFileId
                     andGTIN:(NSString *)gtin
                  completion:(PLYCompletion)completion;


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
                             completion:(PLYCompletion)completion;

// Create a review for a product.
- (void) createReviewForGTIN:(NSString *)gtin
                  dictionary:(NSDictionary *)dictionary
                  completion:(PLYCompletion)completion;
/**
 @name Lists
 */
- (void) createProductList:(PLYList *)list
                completion:(PLYCompletion)completion;

- (void) performSearchForProductListFromUser:(PLYUser *)user
                                 andListType:(NSString *)listType
                                        page:(NSNumber *)page
                              recordsPerPage:(NSNumber *)rpp
                                  completion:(PLYCompletion)completion;

- (void) getProductListWithId:(NSString *)listId
                   completion:(PLYCompletion)completion;

- (void) updateProductList:(PLYList *)list
                completion:(PLYCompletion)completion;

- (void) deleteProductListWithId:(NSString *)listId
                      completion:(PLYCompletion)completion;

/**
 * Add/Remove list items
 **/
- (void) addOrReplaceListItem:(PLYListItem *)listItem
                 toListWithId:(NSString *)listId
                   completion:(PLYCompletion)completion;

- (void) deleteProductWithGTIN:(NSString *)gtin
                 fromListWithId:(NSString *)listId
                     completion:(PLYCompletion)completion;

/**
 * List sharing
 **/
- (void) shareProductListWithId:(NSString *)listId
                     withUserId:(NSString *)userId
                     completion:(PLYCompletion)completion;

- (void) unshareProductListWithId:(NSString *)listId
                       withUserId:(NSString *)userId
                       completion:(PLYCompletion)completion;

/**
 @name Users
 */
- (void) performUserSearch:(NSString *)searchText
                completion:(PLYCompletion)completion;

- (void)  getUserByNickname:(NSString *)nickname
                 completion:(PLYCompletion)completion;

- (void) getAvatarImageUrlFromUser:(PLYUser *)user
                        completion:(PLYCompletion)completion;

- (void) getFollowerFromUser:(NSString *)nickname
                        page:(NSNumber *)page
              recordsPerPage:(NSNumber *)rpp
                  completion:(PLYCompletion)completion;

- (void) getFollowingFromUser:(NSString *)nickname
                         page:(NSNumber *)page
               recordsPerPage:(NSNumber *)rpp
                   completion:(PLYCompletion)completion;

- (void) followUserWithNickname:(NSString *)nickname
                     completion:(PLYCompletion)completion;

- (void) unfollowUserWithNickname:(NSString *)nickname
                       completion:(PLYCompletion)completion;




+ (NSString *)_functionPathForFunction:(NSString *)function
                            parameters:(NSDictionary *)parameters;

+ (NSString *)_addQueryParameterToUrl:(NSString *)url
                           parameters:(NSDictionary *)parameters;
@end
