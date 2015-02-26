//
//  PLYSocialAuthWebViewController.m
//  ProductLayer
//
//  Created by Oliver Drobnik on 6/20/14.
//  Copyright (c) 2015 Cocoanetics. All rights reserved.
//

#import "PLYSocialAuthWebViewController.h"
#import "PLYSocialAuthFunctions.h"

@interface PLYSocialAuthWebViewController () <UIWebViewDelegate>

@end

@implementation PLYSocialAuthWebViewController
{
	NSURLRequest *authorizationRequest;
	
	NSURL *_callbackURL;
	void (^_completionHandler)(BOOL isAuthenticated, NSString *token);
	
	BOOL _isCancelling;
	UIActivityIndicatorView *_activityIndicator;
}

#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
	}
	return self;
}

- (void)loadView
{
	UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	webView.delegate = self;
	self.view = webView;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_activityIndicator.hidesWhenStopped = YES;
	
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
	self.navigationItem.rightBarButtonItem = activityItem;
}

#pragma mark - Helpers

- (UIWebView *)webView
{
	return (UIWebView *)self.view;
}

// checks if the passed URL is indeed the callback URL
- (BOOL)isCallbackURL:(NSURL *)URL
{
	if (![URL.host isEqualToString:_callbackURL.host])
	{
		return NO;
	}
	
	NSString *path = [_callbackURL.path length]?_callbackURL.path:@"/";
	NSString *callbackPath = [URL.path length]?URL.path:@"/";
	
	if (![callbackPath isEqualToString:path])
	{
		return NO;
	}
	
	if (![URL.scheme isEqualToString:_callbackURL.scheme])
	{
		return NO;
	}
	
	return YES;
}

// informs the delegate based on the result
- (void)handleCallbackURL:(NSURL *)URL
{
	NSString *query = [URL query];
	NSDictionary *params = DTOAuthDictionaryFromQueryString(query);
	
	NSString *token = params[@"token"];
	
	if ([token length])
	{
		if ([_authorizationDelegate respondsToSelector:@selector(authorizationWasGranted:forToken:)])
		{
			[_authorizationDelegate authorizationWasGranted:self forToken:token];
		}
		
		if (_completionHandler)
		{
			_completionHandler(YES, token);
		}
	}
	else
	{
		if ([_authorizationDelegate respondsToSelector:@selector(authorizationWasDenied:)])
		{
			[_authorizationDelegate authorizationWasDenied:self];
		}
		
		if (_completionHandler)
		{
			_completionHandler(NO, nil);
		}
	}
	
	_completionHandler = nil;
}

#pragma mark - Public Methods

- (void)startAuthorizationFlowWithRequest:(NSURLRequest *)request completion:(void (^)(BOOL isAuthenticated, NSString *token))completion
{
	if (completion)
	{
		_completionHandler = [completion copy];
	}
	
	authorizationRequest = request;
	
	NSString *query = [request.URL query];
	NSDictionary *params = DTOAuthDictionaryFromQueryString(query);
	
	_callbackURL = [NSURL URLWithString:params[@"callback"]];

	/*
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (NSHTTPCookie *cookie in [storage cookies])
	{
		NSString *domain = cookie.domain;
		
		if ([domain hasSuffix:@".twitter.com"] || [domain hasSuffix:@".facebook.com"])
		{
			
			[storage deleteCookie:cookie];
		}
	}
	 */
	
	[self.webView loadRequest:authorizationRequest];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[_activityIndicator startAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[_activityIndicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[_activityIndicator stopAnimating];
	
	// set nav bar title to title of
	self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if ([request.URL.absoluteString isEqualToString:@"about:blank"])
	{
		[self cancel:nil];
	}
	
	if (_isCancelling)
	{
		return NO;
	}
	
	if (![self isCallbackURL:request.URL])
	{
		return YES;
	}
	
	[self handleCallbackURL:request.URL];
	
	return NO;
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
	if (_isCancelling)
	{
		return;
	}
	
	_isCancelling = YES;
	
	[_authorizationDelegate authorizationWasDenied:self];
	
	if (_completionHandler)
	{
		_completionHandler(NO, nil);
	}
}

@end
