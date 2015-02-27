//
//  PLYSocialAuthWebViewController.h
//  ProductLayer
//
//  Created by Oliver Drobnik on 6/20/14.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

@class PLYSocialAuthWebViewController;


/**
 Protocol for informing a delegate to PLYSocialAuthWebViewController about the authorization result
 */
@protocol PLYSocialAuthResultDelegate <NSObject>

@optional

/**
 Method for informing the delegate that authorization was denied by the user
 @param webViewController The controller sending the message
 */
- (void)authorizationWasDenied:(PLYSocialAuthWebViewController *)webViewController;

/**
 Method for informing the delegate that authorization was granted by the user
 @param webViewController The controller sending the message
 @param token The received authorization token
 */
- (void)authorizationWasGranted:(PLYSocialAuthWebViewController *)webViewController forToken:(NSString *)token;

@end


/**
 View controller with a `UIWebView` as main view. Meant to be embedded in a navigation controller for modal presentation.
 */
@interface PLYSocialAuthWebViewController : UIViewController

// delegate to inform about the authorization result
@property (nonatomic, weak) id <PLYSocialAuthResultDelegate> authorizationDelegate;

/**
 Load the authorization form with a proper auth request from PLYServer
 @param request The authorization URL request
 @param completion The completion handler
 */
- (void)startAuthorizationFlowWithRequest:(NSURLRequest *)request completion:(void (^)(BOOL isAuthenticated, NSString *token))completion;

@end
