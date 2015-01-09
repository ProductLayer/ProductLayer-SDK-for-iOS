//
//  PLYSocialAuthWebViewController.h
//  ProductLayer
//
//  Created by Oliver Drobnik on 6/20/14.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

@class PLYSocialAuthWebViewController;

@protocol OAuthResultDelegate <NSObject>

@optional

/**
 Method for informing the delegate that authorization was denied by the user
 */
- (void)authorizationWasDenied:(PLYSocialAuthWebViewController *)webViewController;

/**
 Method for informing the delegate that authorization was granted by the user
 */
- (void)authorizationWasGranted:(PLYSocialAuthWebViewController *)webViewController forToken:(NSString *)token;

@end


/**
 View controller with a `UIWebView` as main view. Meant to be embedded in a navigation controller for modal presentation.
 */
@interface PLYSocialAuthWebViewController : UIViewController

// delegate to inform about the authorization result
@property (nonatomic, weak) id <OAuthResultDelegate> authorizationDelegate;

/**
 Load the authorization form with a proper OAuth request, this is the request you get from step 2 in DTOAuthClient.
 */
- (void)startAuthorizationFlowWithRequest:(NSURLRequest *)request completion:(void (^)(BOOL isAuthenticated, NSString *token))completion;

@end
