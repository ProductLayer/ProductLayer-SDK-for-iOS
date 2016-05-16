//
//  PLYServer.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYCompatibility.h"
#import "PLYEntities.h"

/**
 Completion handler for ProductLayer API calls
 */
typedef void (^PLYCompletion)(id _Nullable result, NSError * _Nullable error);

/**
 Wrapper for the ProductLayer API
 */
@interface PLYServer : NSObject

/**
 The shared server wrapper.
 */
+ (nullable id)sharedServer;

/**
 Sets the API Key to be used for authenticating the app for using Product Layer.
 @param APIKey The API key (generated on Product Layer app configuration panel)
 */
- (void)setAPIKey:(nullable NSString *)APIKey;

/**
 @name Searching for Products
 */

/**
 Searches for products by GTIN (barcode)
 
 @param gtin The GTIN to search for
 @param language The language code to return results in
 @param completion The completion handler for the request
 */
- (void)performSearchForGTIN:(nonnull NSString *)gtin
                    language:(nullable NSString *)language
                  completion:(nullable PLYCompletion)completion;

/**
 Searches for products by name
 
 @param name The product name to search for
 @param language The language code to return results in
 @param completion The completion handler for the request
 */
- (void)performSearchForName:(nonnull NSString *)name
                    language:(nullable NSString *)language
                  completion:(nullable PLYCompletion)completion;


/**
 Searches for products with a query string
 @param query The text to search for
 @param options Search options
 @param completion The completion handler for the request
 */
- (void)searchForProductsMatchingQuery:(nonnull NSString *)query options:(nullable NSDictionary *)options completion:(nullable PLYCompletion)completion;

/**
 @name Getting more Information about Products
 */

/**
 Retrieves the images for a specific product
 
 @param gtin The GTIN to retrieve images for
 @param completion The completion handler for the request
 */
- (void)getImagesForGTIN:(nonnull NSString *)gtin
              completion:(nullable PLYCompletion)completion;

/**
 Retrieves most recently uploaded images
 
 @param page The page number
 @param rpp The number of results per returned page
 @param completion The completion handler for the request
 */
- (void)getLastUploadedImagesWithPage:(NSInteger)page
                               andRPP:(NSInteger)rpp
                           completion:(nullable PLYCompletion)completion;

/**
 Retrieves a list of categories for a given language
 
 @param language The language code to return results in
 @param completion The completion handler for the request
 */
- (void)getCategoriesForLocale:(nullable NSString *)language
                    completion:(nullable PLYCompletion)completion;

/**
 @name Managing Users
 */

/**
 Creates a new user account
 
 @param user The user's nickname
 @param email The user's e-mail address
 @param completion The completion handler for the request
 */
- (void)createUserWithName:(nonnull NSString *)user
                     email:(nonnull NSString *)email
                completion:(nullable PLYCompletion)completion;

/**
 Authenticates a user for subsequent use of API operations which require authentication
 
 @param user The user's nickname
 @param password The user's password
 @param completion The completion handler for the request
 */
- (void)loginWithUser:(nonnull NSString *)user
             password:(nonnull NSString *)password
           completion:(nullable PLYCompletion)completion;

/**
 Authenticates a user for subsequent use of API operations which require authentication
 @param token The authorization token
 @param completion The completion handler for the request
 */
- (void)loginWithToken:(nonnull NSString *)token completion:(nullable PLYCompletion)completion;

/**
 Invalidates a user's authentication.
 @param completion The completion handler for the request
 */
- (void)logoutUserWithCompletion:(nullable PLYCompletion)completion;

/**
 Checks if user is signed in.
 @param completion The completion handler for the request
 */
- (void)isSignedInWithCompletion:(nullable PLYCompletion)completion;

/**
 Request new password
 @param email The user's e-mail address
 @param completion The completion handler for the request
 */
- (void)requestNewPasswordForUserWithEmail:(nonnull NSString *)email
                                completion:(nullable PLYCompletion)completion;

/**
 Request new password
 @param password The user's new password
 @param resetToken The reset token received by email
 @param completion The completion handler for the request
 */
- (void)setUserPassword:(nonnull NSString *)password resetToken:(nonnull NSString *)resetToken completion:(nullable PLYCompletion)completion;

/**
 Determines an image URL for the given PLYUser
 @param user The PLYUser to retrieve the avatar image URL for
 @returns An NSURL that shows the user's avatar
 */
- (NSURL * _Nonnull)avatarImageURLForUser:(nonnull PLYUser *)user;

/**
 Uploads a new avatar image for currently logged in user
 @param image The new avatar image
 @param user The user to upload an image for
 @param completion The completion handler for the request
 */
- (void)uploadAvatarImage:(DTImage * _Nonnull)image forUser:(nonnull PLYUser *)user completion:(nullable PLYCompletion)completion;

/**
 Resets the avatar image for currently logged in user
 @param user The user to delete the avatar image for
 @param completion The completion handler for the request
 */
- (void)resetAvatarForUser:(nonnull PLYUser *)user completion:(nullable PLYCompletion)completion;

/**
 Sets a communication setting for the  logged in user
 @param setting The name of the setting
 @param parameters The parameters to PUT on the setting
 @param completion The completion handler for the request
 */
- (void)updateSetting:(nonnull NSString *)setting parameters:(nonnull NSDictionary *)parameters completion:(nullable PLYCompletion)completion;


#if TARGET_OS_IPHONE

/**
 Registers the app/device for receiving remote push notification
 @param deviceToken The token returned by the UIApplicationDelegate method
 @param completion The completion handler for the request
 */
- (void)registerPushToken:(nonnull NSData *)deviceToken completion:(nullable PLYCompletion)completion;

#endif

/**
 Refreshes/completes a user's details. Updating of the properties is done on the main thread because some controls might be KVO-watching properties. The completion handler returns the passed user object if successful or nil and an `NSError` if not.
 @param user The user to refresh and/or load updated details for
 @param completion The completion handler for the request
 */
- (void)loadDetailsForUser:(nonnull PLYUser *)user completion:(nullable PLYCompletion)completion;

/**
 Loads the achievements for the given user
 @param user The user to load achievements for
 @param completion The completion handler for the request
 */
- (void)loadAchievementsForUser:(nonnull PLYUser *)user completion:(nullable PLYCompletion)completion;

/**
 Nickname of the currently logged in user or `nil` if not logged in
 */
@property (nonatomic, readonly) PLYUser * _Nullable loggedInUser;

/**
 Property that states if a login action is currently happening
 */
@property (nonatomic, readonly) BOOL performingLogin;


/**
 @name Managing Social Connections
 */

/**
 Provides an URL request for the social signin flow for Facebook
 @returns A configured NSURLRequest for presenting in a web view
 */
- (nonnull NSURLRequest *)URLRequestForFacebookSignIn;

/**
 Provides an URL request for the social connect flow for Facebook. This connects the service with the currently logged in user.
 @returns A configured NSURLRequest for presenting in a web view
 */
- (nonnull NSURLRequest *)URLRequestForFacebookConnect;

/**
 Removes the Facebook social connection for the logged in user.
 @param completion The completion handler for the request
 */
- (void)disconnectSocialConnectionForFacebook:(nullable PLYCompletion)completion;

/**
 Provides an URL request for the social signin flow for Twitter
 @returns A configured NSURLRequest for presenting in a web view
 */
- (nonnull NSURLRequest *)URLRequestForTwitterSignIn;

/**
 Provides an URL request for the social connect flow for Twitter. This connects the service with the currently logged in user.
 @returns A configured NSURLRequest for presenting in a web view
 */
- (nonnull NSURLRequest *)URLRequestForTwitterConnect;

/**
 Removes the Twitter social connection for the logged in user.
 @param completion The completion handler for the request
 */
- (void)disconnectSocialConnectionForTwitter:(nullable PLYCompletion)completion;


/**
 @name Managing Products
 */

/**
 Creates a new product.
 
 @param product The new PLYProduct to create
 @param completion The completion handler for the request
 */
- (void)createProduct:(nonnull PLYProduct *)product completion:(nullable PLYCompletion)completion;

/**
 Updates an existing product.
 
 @param product The new PLYProduct to update
 @param completion The completion handler for the request
 */
- (void)updateProduct:(nonnull PLYProduct *)product completion:(nullable PLYCompletion)completion;


/**
 @name Working with Brands and Brand Owners
 */

/**
 Retrieves the recommended brand owners based on GTIN
 @param GTIN The GTIN of the product
 @param completion The completion handler for the request
 */
- (void)recommendedBrandOwnersForGTIN:(nonnull NSString *)GTIN
                           completion:(nullable PLYCompletion)completion;

/**
 Retrieves a list of all known brands
 @param completion The completion handler for the request
 */
- (void)brandsWithCompletion:(nullable PLYCompletion)completion;

/**
 Retrieves a list of all known brand owners
 @param completion The completion handler for the request
 */
- (void)brandOwnersWithCompletion:(nullable PLYCompletion)completion;


/**
 @name Vote Handling
 */

/*
 Upvote an votable entity.
 
 @param voteableEntity The entity which should be upvoted.
 @param completion The completion handler for the request
 */
- (void)upVote:(nonnull PLYVotableEntity *)voteableEntity
    completion:(nullable PLYCompletion)completion;

/*
 Downvote an votable entity.
 
 @param voteableEntity The entity which should be downvoted.
 @param completion The completion handler for the request
 */
- (void)downVote:(nonnull PLYVotableEntity *)voteableEntity
      completion:(nullable PLYCompletion)completion;

/**
 @name Image Handling
 */

/**
 Uploads an image to be associated with a specific product
 
 @param data The image data
 @param gtin The GTIN (barcode) of the new product
 @param completion The completion handler for the request
 */
- (void)uploadImageData:(nonnull DTImage *)data
                forGTIN:(nonnull NSString *)gtin
             completion:(nullable PLYCompletion)completion;

/**
 @param image The image to delete
 @param completion The completion handler for the request
 */
- (void)deleteImage:(nonnull PLYImage *)image completion:(nullable PLYCompletion)completion;

/**
 @param image The image to rotate
 @param degrees The amount to rotate by, allowed values are: 90, 180, 270
 @param completion The completion handler for the request
 */
- (void)rotateImage:(nonnull PLYImage *)image degrees:(NSUInteger)degrees completion:(nullable PLYCompletion)completion;

/**
 Determins the image URL for the given image with a maximum size and optional crop
 @param image The image to retrieve the URL for
 @param maxWidth The maximum width of the image
 @param maxHeight The maximum height of the image
 @param crop If the image should be cropped
 @returns The URL for the image
 */
- (nonnull NSURL *)URLForImage:(nonnull PLYImage *)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight crop:(BOOL)crop;

/**
 Determins the image URL for the given default image for a given GTIN
 @param GTIN The GTIN to produce the URL for
 @param maxWidth The maximum width of the image
 @param maxHeight The maximum height of the image
 @param crop If the image should be cropped
 @returns The URL for the image
 */
- (nonnull NSURL *)URLForProductImageWithGTIN:(nonnull NSString *)GTIN maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight crop:(BOOL)crop;

/**
 @name Opines
 */

/**
 Searches for opines
 
 @param gtin The GTIN (barcode) of the product
 @param language The language code to return results in
 @param nickname The user to restrict the results to. Pass `nil` to return all user's reviews.
 @param showFriendsOnly If true shows only opines from friends.
 @param orderBy The key to order results by, e.g. "pl-created-time_desc"
 @param page The page number
 @param rpp The number of results per returned page
 @param completion The completion handler for the request
 */
- (void) performSearchForOpineWithGTIN:(nonnull NSString *)gtin
                          withLanguage:(nullable NSString *)language
                  fromUserWithNickname:(nonnull NSString *)nickname
                       showFriendsOnly:(BOOL)showFriendsOnly
                               orderBy:(nonnull NSString *)orderBy
                                  page:(NSUInteger)page
                        recordsPerPage:(NSUInteger)rpp
                            completion:(nullable PLYCompletion)completion;

/**
 Create an opine.
 
 @param opine The opine
 @param completion The completion handler for the request
 */
- (void)createOpine:(nonnull PLYOpine *)opine completion:(nullable PLYCompletion)completion;

/**
 Refreshes an opine from the server.
 
 @param opine The opine
 @param completion The completion handler for the request
 */
- (void)refreshOpine:(nonnull PLYOpine *)opine completion:(nullable PLYCompletion)completion;


/**
 Destroy an opine.
 @param opine The opine
 @param completion The completion handler for the request
 */
- (void)deleteOpine:(nonnull PLYOpine *)opine completion:(nullable PLYCompletion)completion;

/**
 @name Reviews
 */

/**
 Searches for reviews
 
 @param gtin The GTIN (barcode) of the product
 @param language The language code to return results in
 @param nickname The user to restrict the results to. Pass `nil` to return all user's reviews.
 @param rating The rating to restrict results to. Pass `nil` to return all reviews regardless of rating.
 @param orderBy The key to order results by, e.g. "pl-created-time_desc"
 @param page The page number
 @param rpp The number of results per returned page
 @param completion The completion handler for the request
 */
- (void)performSearchForReviewWithGTIN:(nonnull NSString *)gtin
                          withLanguage:(nullable NSString *)language
                  fromUserWithNickname:(nonnull NSString *)nickname
                            withRating:(float)rating
                               orderBy:(nonnull NSString *)orderBy
                                  page:(NSUInteger)page
                        recordsPerPage:(NSUInteger)rpp
                            completion:(nullable PLYCompletion)completion;


/**
 @name Lists
 */

/**
 Creates a new product list for the logged in user
 @param list The list to create
 @param completion The completion handler for the request
 */
- (void)createProductList:(nonnull PLYList *)list completion:(nullable PLYCompletion)completion;

/**
 Finds a user's lists
 @param user The user for which to search the list for
 @param listType The list type to search for
 @param page The page number to retrieve of the search results
 @param rpp The records per page to retrieve
 @param completion The completion handler for the request
 */
- (void)performSearchForProductListFromUser:(nonnull PLYUser *)user andListType:(nonnull NSString *)listType page:(NSUInteger)page recordsPerPage:(NSUInteger)rpp completion:(nullable PLYCompletion)completion;

/**
 Gets a user's lists
 @param user The PLYUser to retrieve the lists for
 @param options options to restrict the lists
 @param completion The completion handler for the request
 */
- (void)listsOfUser:(nonnull PLYUser *)user options:(nullable NSDictionary *)options completion:(nullable PLYCompletion)completion;

/**
 Retrieves a product list by ID
 @param listId The identifier of the list to retrieve
 @param completion The completion handler for the request
 */
- (void)getProductListWithId:(nonnull NSString *)listId completion:(nullable PLYCompletion)completion;

/**
 Updates a product list for the logged in user
 @param list The list to create
 @param completion The completion handler for the request
 */
- (void)updateProductList:(nonnull PLYList *)list completion:(nullable PLYCompletion)completion;

/**
 Deletes a product list by ID
 @param listId The identifier of the list to retrieve
 @param completion The completion handler for the request
 */
- (void)deleteProductListWithId:(nonnull NSString *)listId completion:(nullable PLYCompletion)completion;

/**
 Add/Remove list items
 @param listItem The list item
 @param listId The list identifier
 @param completion The completion handler
 */
- (void)addOrReplaceListItem:(nonnull PLYListItem *)listItem toListWithId:(nonnull NSString *)listId completion:(nullable PLYCompletion)completion;

/**
 Delete product with GTIN from list.
 @param gtin The GTIN (barcode) of the product
 @param listId The list identifier
 @param completion The completion handler
 */
- (void)deleteProductWithGTIN:(nonnull NSString *)gtin fromListWithId:(nonnull NSString *)listId completion:(nullable PLYCompletion)completion;

/**
 @name List sharing
 */

/**
 Shares a product list with another user
 @param listId The identifier of the list to share
 @param userId The identifier of the user to give access to the list
 @param completion The completion handler for the request
 */
- (void)shareProductListWithId:(nonnull NSString *)listId withUserId:(nonnull NSString *)userId completion:(nullable PLYCompletion)completion;

/**
 Removes list access from another user
 @param listId The identifier of the list to share
 @param userId The identifier of the user to give access to the list
 @param completion The completion handler for the request
 */
- (void)unshareProductListWithId:(nonnull NSString *)listId withUserId:(nonnull NSString *)userId completion:(nullable PLYCompletion)completion;

/*
 @name Managing User Relationships
 */

/**
 Search for a user by name
 @param query The text to search for
 @param completion The completion handler for the request
 */
- (void)searchForUsersMatchingQuery:(nonnull NSString *)query completion:(nullable PLYCompletion)completion;

/**
 Retrieves a user by nickname
 @param nickname The nickname to search for
 @param completion The completion handler for the request
 */
- (void)getUserByNickname:(nonnull NSString *)nickname completion:(nullable PLYCompletion)completion;

/**
 Retrieves a user's followers
 @param user The user for whom you want to get the followers
 @param options A dictionary with options to determine paging options
 @param completion The completion handler for the request
 */
- (void)followerForUser:(nonnull PLYUser *)user options:(NSDictionary * _Nullable)options completion:(nullable PLYCompletion)completion;

/**
 Retrieves the friends a user is following
 @param user The user for whom you want to get the followers
 @param options A dictionary with options to determine paging options
 @param completion The completion handler for the request
 */
- (void)followingForUser:(nonnull PLYUser *)user options:(NSDictionary * _Nullable)options completion:(nullable PLYCompletion)completion;

/**
 Follows a user by nickname
 @param user The user to follow
 @param completion The completion handler for the request
 */
- (void)followUser:(nonnull PLYUser *)user completion:(nullable PLYCompletion)completion;

/**
 Unfollows a user by nickname
 @param user The user to follow
 @param completion The completion handler for the request
 */
- (void)unfollowUser:(nonnull PLYUser *)user completion:(nullable PLYCompletion)completion;


/**
 @name Timelines
 */

/**
 Get a user's timeline
 @param user The user for whom you want to get the timeline
 @param options A dictionary with options to determine which entities to include
 @param completion The completion handler for the request
 */
- (void)timelineForUser:(nonnull PLYUser *)user
                options:(nullable NSDictionary *)options
             completion:(nullable PLYCompletion)completion;

/**
 The the latest timeline entries for a specific product
 @param product The PLYProduct to retrieve the timeline for
 @param options A dictionary with options to determine which entities to include
 @param completion The completion handler for the request
 */
- (void)timelineForProduct:(nonnull PLYProduct *)product
                   options:(nullable NSDictionary *)options
                completion:(nullable PLYCompletion)completion;

/**
 @name Reporting Issues
 */

/**
 Reports a problem with a given entity, which can either be a PLYImage, PLYUser, PLYUserAvater or PLYProduct
 @param report The problem report to send create
 @param completion The completion handler for the request
 */
- (void)createProblemReport:(nonnull PLYProblemReport *)report completion:(nullable PLYCompletion)completion;

/**
 @name Working with Categories
 */

- (nonnull NSArray *)categoriesMatchingSearch:(nonnull NSString *)search;


/**
 Retrieves the PLCategory object for a given key and language
 @param key The category key
 @param language The language to retrieve the category for
 @param completion The completion handler for the request
 */
- (void)categoryForKey:(nonnull NSString *)key language:(nullable NSString *)language completion:(nullable PLYCompletion)completion;

/**
 Retrieves all top-level PLCategory object for a given language
 @param language The language to retrieve the category for or `nil` to return the best matching language
 @param completion The completion handler for the request
 */
- (void)categoriesWithLanguage:(nullable NSString *)language completion:(nullable PLYCompletion)completion;

/**
 Returns a path string that concatenates the localized category names separated by slashes for a given category key
 @param categoryKey The key of the category
 @returns The category path string
 */
- (nonnull NSString *)localizedCategoryPathForKey:(nonnull NSString *)categoryKey;

/**
 @name Entity Handling
 */

/**
 Retrieves an entity by its type and identifier
 @param identifier The server-side identifier of the entity
 @param class The PLYEntity subclass for the entity
 @param completion The completion handler for the request
 @returns A previously cached entity or `nil`
 */
- (nullable PLYEntity *)retrieveEntityByIdentifier:(nonnull NSString *)identifier class:(nonnull Class)class completion:(nullable PLYCompletion)completion;

@end
