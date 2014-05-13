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

/**
 Wrapper for the ProductLayer API
 */
@interface PLYServer : NSObject

/**
 The shared server wrapper.
 */
+ (id)sharedServer;

/**
 @name Searching for Products
 */

/**
 Searches for products by GTIN (barcode)
 
 @param gtin The GTIN to search for
 @param language The language code to return results in
 @param completion The completion handler for the request
 */
- (void)performSearchForGTIN:(NSString *)gtin
                    language:(NSString *)language
                  completion:(PLYCompletion)completion;

/** 
 Searches for products by name

 @param name The product name to search for
 @param language The language code to return results in
 @param completion The completion handler for the request
*/
- (void)performSearchForName:(NSString *)name
                    language:(NSString *)language
                  completion:(PLYCompletion)completion;


/**
 @name Getting more Information about Products
 */

/**
 Retrieves the images for a specific product
 
 @param gtin The GTIN to retrieve images for
 @param completion The completion handler for the request
 */
- (void)getImagesForGTIN:(NSString *)gtin
              completion:(PLYCompletion)completion;

/**
 Retrieves most recently uploaded images
 
 @param page The page number
 @param rpp The number of results per returned page
 @param completion The completion handler for the request
 */
- (void)getLastUploadedImagesWithPage:(NSInteger)page
                               andRPP:(NSInteger)rpp
                           completion:(PLYCompletion)completion;

/**
 Retrieves a list of categories for a given language
 
 @param language The language code to return results in
 @param completion The completion handler for the request
 */
- (void)getCategoriesForLocale:(NSString *)language
                    completion:(PLYCompletion)completion;

/**
 @name Managing Users
 */

/**
 Creates a new user account
 
 @param user The user's nickname
 @param email The user's e-mail address
 @param completion The completion handler for the request
 */
- (void)createUserWithName:(NSString *)user
                     email:(NSString *)email
                completion:(PLYCompletion)completion;

/**
 Authenticates a user for subsequent use of API operations which require authentication
 
 @param user The user's nickname
 @param password The user's password
 @param completion The completion handler for the request
 */
- (void)loginWithUser:(NSString *)user
             password:(NSString *)password
           completion:(PLYCompletion)completion;

/**
 Invalidates a user's authentication.
 
 @param completion The completion handler for the request
 */
- (void)logoutUserWithCompletion:(PLYCompletion)completion;

/**
 Request new password
 
 @param email The user's e-mail address
 @param completion The completion handler for the request
 */
- (void)requestNewPasswordForUserWithEmail:(NSString *)email
                                completion:(PLYCompletion)completion;

/**
 Nickname of the currently logged in user or `nil` if not logged in
 */
@property (nonatomic, readonly) PLYUser *loggedInUser;


/**
 @name Managing Products
 */

/**
 Creates a new product.
 
 @param gtin The GTIN (barcode) of the new product
 @param dictionary The values to set on the new product
 @param completion The completion handler for the request
 */
- (void)createProductWithGTIN:(NSString *)gtin
                   dictionary:(NSDictionary *)dictionary
                   completion:(PLYCompletion)completion;

/**
 Updates an existing product.
 
 @param gtin The GTIN (barcode) of the product
 @param dictionary The values to set on the product
 @param completion The completion handler for the request
 */
- (void)updateProductWithGTIN:(NSString *)gtin
                   dictionary:(NSDictionary *)dictionary
                   completion:(PLYCompletion)completion;

/**
 @name Image Handling
 */

/**
 Uploads an image to be associated with a specific product
 
 @param data The image data
 @param gtin The GTIN (barcode) of the new product
 @param completion The completion handler for the request
 */
- (void)uploadImageData:(UIImage *)data
                forGTIN:(NSString *)gtin
             completion:(PLYCompletion)completion;

/**
 Adds a 'thumbs up' vote to a specific product image. An authenticated user can only vote once.
 
 @param imageFileId The image file identifier
 @param gtin The GTIN (barcode) of the product
 @param completion The completion handler for the request
 */
- (void)upVoteImageWithId:(NSString *)imageFileId
                  andGTIN:(NSString *)gtin
               completion:(PLYCompletion)completion;

/**
 Adds a 'thumbs down' vote to a specific product image. An authenticated user can only vote once.
 
 @param imageFileId The image file identifier
 @param gtin The GTIN (barcode) of the product
 @param completion The completion handler for the request
 */
- (void)downVoteImageWithId:(NSString *)imageFileId
                    andGTIN:(NSString *)gtin
                 completion:(PLYCompletion)completion;

/**
 @name Reviews
 */

/**
 Searches for reviews
 
 @param gtin The GTIN (barcode) of the product
 @param language The language code to return results in
 @param completion The completion handler for the request
 @param nickname The user to restrict the results to. Pass `nil` to return all user's reviews.
 @param rating The rating to restrict results to. Pass `nil` to return all reviews regardless of rating.
 @param orderBy The key to order results by, e.g. "pl-created-time_desc"
 @param page The page number
 @param rpp The number of results per returned page
 @param completion The completion handler for the request
 */
- (void)performSearchForReviewWithGTIN:(NSString *)gtin
                          withLanguage:(NSString *)language
                  fromUserWithNickname:(NSString *)nickname
                            withRating:(NSNumber *)rating
                               orderBy:(NSString *)orderBy
                                  page:(NSNumber *)page
                        recordsPerPage:(NSNumber *)rpp
                            completion:(PLYCompletion)completion;

/*
 Create a review for a product.
 
 @param gtin The GTIN (barcode) of the product
 @param dictionary The review keys and values to set
 @param completion The completion handler for the request
 */
- (void)createReviewForGTIN:(NSString *)gtin
                 dictionary:(NSDictionary *)dictionary
                 completion:(PLYCompletion)completion;
/**
 @name Lists
 */
- (void)createProductList:(PLYList *)list completion:(PLYCompletion)completion;

- (void)performSearchForProductListFromUser:(PLYUser *)user andListType:(NSString *)listType page:(NSNumber *)page recordsPerPage:(NSNumber *)rpp completion:(PLYCompletion)completion;

- (void)getProductListWithId:(NSString *)listId completion:(PLYCompletion)completion;

- (void)updateProductList:(PLYList *)list completion:(PLYCompletion)completion;

- (void)deleteProductListWithId:(NSString *)listId completion:(PLYCompletion)completion;

/**
 Add/Remove list items
 @param listItem The list item
 @param listId The list identifier
 @param completion The completion handler
 */
- (void)addOrReplaceListItem:(PLYListItem *)listItem toListWithId:(NSString *)listId completion:(PLYCompletion)completion;

- (void)deleteProductWithGTIN:(NSString *)gtin fromListWithId:(NSString *)listId completion:(PLYCompletion)completion;

/**
 @name List sharing
 */
- (void)shareProductListWithId:(NSString *)listId withUserId:(NSString *)userId completion:(PLYCompletion)completion;

- (void)unshareProductListWithId:(NSString *)listId withUserId:(NSString *)userId completion:(PLYCompletion)completion;

/*
 @name Managing User Relationships
 */
- (void)performUserSearch:(NSString *)searchText completion:(PLYCompletion)completion;

- (void)getUserByNickname:(NSString *)nickname completion:(PLYCompletion)completion;

- (void)getAvatarImageUrlFromUser:(PLYUser *)user completion:(PLYCompletion)completion;

- (void)getFollowerFromUser:(NSString *)nickname page:(NSNumber *)page recordsPerPage:(NSNumber *)rpp completion:(PLYCompletion)completion;

- (void)getFollowingFromUser:(NSString *)nickname page:(NSNumber *)page recordsPerPage:(NSNumber *)rpp completion:(PLYCompletion)completion;

- (void)followUserWithNickname:(NSString *)nickname completion:(PLYCompletion)completion;

- (void)unfollowUserWithNickname:(NSString *)nickname completion:(PLYCompletion)completion;

@end
