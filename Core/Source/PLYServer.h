//
//  PLYServer.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "PLYCompatibility.h"

/**
 Completion handler for ProductLayer API calls
 */
typedef void (^PLYCompletion)(id result, NSError *error);

// String Constants

@class PLYImage;
@class PLYList;
@class PLYListItem;
@class PLYOpine;
@class PLYProduct;
@class PLYReview;
@class PLYUser;
@class PLYVotableEntity;

/**
 Wrapper for the ProductLayer API
 */
@interface PLYServer : NSObject

/**
 The shared server wrapper.
 */
+ (id)sharedServer;

/**
 Sets the API Key to be used for authenticating the app for using Product Layer.
 @param APIKey The API key (generated on Product Layer app configuration panel)
 */
- (void)setAPIKey:(NSString *)APIKey;

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
 Renew the user session if the user was logged in but the session timed out.
 */
- (void)renewSessionIfNecessary;

/**
 Checks if user is signed in.
 @param completion The completion handler for the request
 */
- (void)isSignedInWithCompletion:(PLYCompletion)completion;

/**
 Request new password
 @param email The user's e-mail address
 @param completion The completion handler for the request
 */
- (void)requestNewPasswordForUserWithEmail:(NSString *)email
                                completion:(PLYCompletion)completion;

/**
 Determines an image URL for the given PLYUser
 @param user The PLYUser to retrieve the avatar image URL for
 @returns An NSURL that shows the user's avatar
 */
- (NSURL *)avatarImageURLForUser:(PLYUser *)user;

/**
 Uploads a new avatar image for currently logged in user
 @param image The new avatar image
 @param user The user to upload an image for
 @param completion The completion handler for the request
 */
- (void)uploadAvatarImage:(DTImage *)image forUser:(PLYUser *)user completion:(PLYCompletion)completion;

/**
 Resets the avatar image for currently logged in user
 @param user The user to delete the avatar image for
 @param completion The completion handler for the request
 */
- (void)resetAvatarForUser:(PLYUser *)user completion:(PLYCompletion)completion;

/**
 Refreshes/completes a user's details. Updating of the properties is done on the main thread because some controls might be KVO-watching properties. The completion handler returns the passed user object if successful or nil and an `NSError` if not.
 @param user The user to refresh and/or load updated details for
 @param completion The completion handler for the request
 */
- (void)loadDetailsForUser:(PLYUser *)user completion:(PLYCompletion)completion;

/**
 Nickname of the currently logged in user or `nil` if not logged in
 */
@property (nonatomic, readonly) PLYUser *loggedInUser;

/**
 Property that states if a login action is currently happening
 */
@property (nonatomic, readonly) BOOL performingLogin;


/**
 @name Managing Products
 */

/**
 Creates a new product.
 
 @param product The new PLYProduct to create
 @param completion The completion handler for the request
 */
- (void)createProduct:(PLYProduct *)product completion:(PLYCompletion)completion;

/**
 Updates an existing product.
 
 @param product The new PLYProduct to update
 @param completion The completion handler for the request
 */
- (void)updateProduct:(PLYProduct *)product completion:(PLYCompletion)completion;


/**
 @name Working with Brands and Brand Owners
 */

/**
 Retrieves the recommended brand owners based on GTIN
 @param GTIN The GTIN of the product
 @param completion The completion handler for the request
 */
- (void)getRecommendedBrandOwnersForGTIN:(NSString *)GTIN
										completion:(PLYCompletion)completion;

/**
 Retrieves a list of all known brands
 @param completion The completion handler for the request
 */
- (void)getBrandsWithCompletion:(PLYCompletion)completion;


/**
 @name Vote Handling
 */

/*
 Upvote an votable entity.
 
 @param voteableEntity The entity which should be upvoted.
 @param completion The completion handler for the request
 */
- (void)upVote:(PLYVotableEntity *)voteableEntity
    completion:(PLYCompletion)completion;

/*
 Downvote an votable entity.
 
 @param voteableEntity The entity which should be downvoted.
 @param completion The completion handler for the request
 */
- (void)downVote:(PLYVotableEntity *)voteableEntity
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
- (void)uploadImageData:(DTImage *)data
                forGTIN:(NSString *)gtin
             completion:(PLYCompletion)completion;

/**
 Determins the image URL for the given image with a maximum size and optional crop
 @param image The image to retrieve the URL for
 @param maxWidth The maximum width of the image
 @param maxHeight The maximum height of the image
 @param crop If the image should be cropped
 @returns The URL for the image
 */
- (NSURL *)URLForImage:(PLYImage *)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight crop:(BOOL)crop;

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
- (void) performSearchForOpineWithGTIN:(NSString *)gtin
                          withLanguage:(NSString *)language
                  fromUserWithNickname:(NSString *)nickname
                        showFriendsOnly:(BOOL *)showFriendsOnly
                               orderBy:(NSString *)orderBy
                                  page:(NSUInteger)page
                        recordsPerPage:(NSUInteger)rpp
                            completion:(PLYCompletion)completion;

/**
 Create an opine.
 
 @param opine The opine
 @param completion The completion handler for the request
 */
- (void)createOpine:(PLYOpine *)opine completion:(PLYCompletion)completion;

/**
 Destroy an opine.
 @param opine The opine
 @param completion The completion handler for the request
 */
- (void)deleteOpine:(PLYOpine *)opine completion:(PLYCompletion)completion;

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
- (void)performSearchForReviewWithGTIN:(NSString *)gtin
                          withLanguage:(NSString *)language
                  fromUserWithNickname:(NSString *)nickname
                            withRating:(float)rating
                               orderBy:(NSString *)orderBy
                                  page:(NSUInteger)page
                        recordsPerPage:(NSUInteger)rpp
                            completion:(PLYCompletion)completion;

/*
 Create a review for a product.
 
 @param review The PLYReview to create
 @param completion The completion handler for the request
 */
- (void)createReview:(PLYReview *)review completion:(PLYCompletion)completion;

/**
 @name Lists
 */

/**
 Creates a new product list for the logged in user
 @param list The list to create
 @param completion The completion handler for the request
 */
- (void)createProductList:(PLYList *)list completion:(PLYCompletion)completion;

/**
 Finds a user's lists
 @param user The user for which to search the list for
 @param listType The list type to search for
 @param page The page number to retrieve of the search results
 @param rpp The records per page to retrieve
 @param completion The completion handler for the request
 */
- (void)performSearchForProductListFromUser:(PLYUser *)user andListType:(NSString *)listType page:(NSUInteger)page recordsPerPage:(NSUInteger)rpp completion:(PLYCompletion)completion;

/**
 Retrieves a product list by ID
 @param listId The identifier of the list to retrieve
 @param completion The completion handler for the request
 */
- (void)getProductListWithId:(NSString *)listId completion:(PLYCompletion)completion;

/**
 Updates a product list for the logged in user
 @param list The list to create
 @param completion The completion handler for the request
 */
- (void)updateProductList:(PLYList *)list completion:(PLYCompletion)completion;

/**
 Deletes a product list by ID
 @param listId The identifier of the list to retrieve
 @param completion The completion handler for the request
 */
- (void)deleteProductListWithId:(NSString *)listId completion:(PLYCompletion)completion;

/**
 Add/Remove list items
 @param listItem The list item
 @param listId The list identifier
 @param completion The completion handler
 */
- (void)addOrReplaceListItem:(PLYListItem *)listItem toListWithId:(NSString *)listId completion:(PLYCompletion)completion;

/**
 Delete product with GTIN from list.
 @param gtin The GTIN (barcode) of the product
 @param listId The list identifier
 @param completion The completion handler
 */
- (void)deleteProductWithGTIN:(NSString *)gtin fromListWithId:(NSString *)listId completion:(PLYCompletion)completion;

/**
 @name List sharing
 */

/**
 Shares a product list with another user
 @param listId The identifier of the list to share
 @param userId The identifier of the user to give access to the list
 @param completion The completion handler for the request
 */
- (void)shareProductListWithId:(NSString *)listId withUserId:(NSString *)userId completion:(PLYCompletion)completion;

/**
 Removes list access from another user
 @param listId The identifier of the list to share
 @param userId The identifier of the user to give access to the list
 @param completion The completion handler for the request
 */
- (void)unshareProductListWithId:(NSString *)listId withUserId:(NSString *)userId completion:(PLYCompletion)completion;

/*
 @name Managing User Relationships
 */

/**
 Search for a user by name
 @param searchText The text to search for
 @param completion The completion handler for the request
 */
- (void)performUserSearch:(NSString *)searchText completion:(PLYCompletion)completion;

/**
 Retrieves a user by nickname
 @param nickname The nickname to search for
 @param completion The completion handler for the request
 */
- (void)getUserByNickname:(NSString *)nickname completion:(PLYCompletion)completion;

/**
 Retrieves a user's followers
 @param nickname The nickname to search for
 @param page The page number to retrieve of the search results
 @param rpp The records per page to retrieve
 @param completion The completion handler for the request
 */
- (void)getFollowerFromUser:(NSString *)nickname page:(NSUInteger)page recordsPerPage:(NSUInteger)rpp completion:(PLYCompletion)completion;

/**
 Retrieves the friends a user is following
 @param nickname The nickname to search for
 @param page The page number to retrieve of the search results
 @param rpp The records per page to retrieve
 @param completion The completion handler for the request
 */
- (void)getFollowingFromUser:(NSString *)nickname page:(NSUInteger)page recordsPerPage:(NSUInteger)rpp completion:(PLYCompletion)completion;

/**
 Follows a user by nickname
 @param user The user to follow
 @param completion The completion handler for the request
 */
- (void)followUser:(PLYUser *)user completion:(PLYCompletion)completion;

/**
 Unfollows a user by nickname
 @param user The user to follow
 @param completion The completion handler for the request
 */
- (void)unfollowUser:(PLYUser *)user completion:(PLYCompletion)completion;


- (void)followerForUser:(PLYUser *)user completion:(PLYCompletion)completion;
- (void)followingForUser:(PLYUser *)user completion:(PLYCompletion)completion;

/**
 @name Timelines
 */

/**
 Get a user's timeline
 @param user The user for whom you want to get the timeline
 @param options A dictionary with options to determine which entities to include
 @param completion The completion handler for the request
 */
- (void)timelineForUser:(PLYUser *)user
					 options:(NSDictionary *)options
				 completion:(PLYCompletion)completion;

/**
 The the latest timeline entries for a specific product
 @param product The PLYProduct to retrieve the timeline for
 @param options A dictionary with options to determine which entities to include
 @param completion The completion handler for the request
 */
- (void)timelineForProduct:(PLYProduct *)product
						 options:(NSDictionary *)options
                completion:(PLYCompletion)completion;



@end
