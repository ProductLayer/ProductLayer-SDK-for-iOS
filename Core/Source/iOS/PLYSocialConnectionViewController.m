//
//  PLYSocialConnectionViewController.m
//  ProdlyApp
//
//  Created by Oliver Drobnik on 22/03/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYSocialConnectionViewController.h"
#import "UIViewController+ProductLayer.h"
#import "ProductLayerSDK.h"

#import "DTBlockFunctions.h"
#import "PLYSocialAuthWebViewController.h"

#define ROW_FACEBOOK 0
#define ROW_TWITTER 1

@interface PLYSocialConnectionViewController ()

@end

@implementation PLYSocialConnectionViewController
{
	BOOL _isFacebookBusy;
	BOOL _isTwitterBusy;
	
	UILabel *_explainLabel;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationItem.title = PLYLocalizedStringFromTable(@"SOCIAL_CONNECTIONS_TITLE", @"UI", @"Title of the Social Connections Dialog");
	
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	
	NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	style.alignment = NSTextAlignmentJustified;
	style.firstLineHeadIndent = 20.0f;
	style.headIndent = 20.0f;
	style.tailIndent = -20.0f;
	
	NSString *text = PLYLocalizedStringFromTable(@"SOCIAL_CONNECTIONS_MSG", @"UI", @"Explanation of what the social connections are for");
	NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{ NSParagraphStyleAttributeName : style,
																																				  NSForegroundColorAttributeName: [UIColor grayColor]}];
	
	NSRange prodlyRange = [text rangeOfString:@"prod.ly"];
	
	if (prodlyRange.location != NSNotFound)
	{
		[attrText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:prodlyRange];
		prodlyRange.location +=5;
		prodlyRange.length = 2;
		[attrText addAttribute:NSForegroundColorAttributeName value:PLYBrandColor() range:prodlyRange];
	}
	
	label.numberOfLines = 0;
	label.attributedText = attrText;
	
	_explainLabel = label;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return _explainLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	_explainLabel.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 10000);
	[_explainLabel sizeToFit];
	
	return _explainLabel.frame.size.height + 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
	
	switch (indexPath.row)
	{
		case ROW_FACEBOOK:
		{
			NSString *facebookPath = [PLYResourceBundle() pathForResource:@"facebook-button" ofType:@"png"];
			UIImage *facebookIcon = [[UIImage imageWithContentsOfFile:facebookPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
			NSAssert(facebookIcon!=nil, @"Missing Facebook icon in resource bundle");
			
			cell.imageView.image = facebookIcon;
			cell.textLabel.text = @"Facebook";
			
			if (_isFacebookBusy)
			{
				UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				[activity startAnimating];
				cell.accessoryView = activity;
			}
			else
			{
				UIButton *connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
				
				if ([self.productLayerServer.loggedInUser.socialConnections[@"facebook"] boolValue])
				{
					connectButton.tintColor = [UIColor redColor];
					[connectButton setTitle:PLYLocalizedStringFromTable(@"DISCONNECT", @"UI", @"Action to disconnect a social connection") forState:UIControlStateNormal];
					[connectButton addTarget:self action:@selector(disconnectFacebook:) forControlEvents:UIControlEventTouchUpInside];
				}
				else
				{
					[connectButton setTitle:PLYLocalizedStringFromTable(@"CONNECT", @"UI", @"Action to connect a social connection") forState:UIControlStateNormal];
					[connectButton addTarget:self action:@selector(connectFacebook:) forControlEvents:UIControlEventTouchUpInside];
				}
				
				[connectButton sizeToFit];
				cell.accessoryView = connectButton;
			}
			
			break;
		}
			
		case ROW_TWITTER:
		{
			NSString *twitterPath = [PLYResourceBundle() pathForResource:@"twitter-button" ofType:@"png"];
			UIImage *twitterIcon = [[UIImage imageWithContentsOfFile:twitterPath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
			NSAssert(twitterIcon!=nil, @"Missing Twitter icon in resource bundle");

			cell.imageView.image = twitterIcon;
			cell.textLabel.text = @"Twitter";
			
			if (_isTwitterBusy)
			{
				UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
				[activity startAnimating];
				cell.accessoryView = activity;
			}
			else
			{
				UIButton *connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
				
				if ([self.productLayerServer.loggedInUser.socialConnections[@"twitter"] boolValue])
				{
					connectButton.tintColor = [UIColor redColor];
					[connectButton setTitle:PLYLocalizedStringFromTable(@"DISCONNECT", @"UI", @"Action to disconnect a social connection") forState:UIControlStateNormal];
					[connectButton addTarget:self action:@selector(disconnectTwitter:) forControlEvents:UIControlEventTouchUpInside];
				}
				else
				{
					[connectButton setTitle:PLYLocalizedStringFromTable(@"CONNECT", @"UI", @"Action to connect a social connection") forState:UIControlStateNormal];
					[connectButton addTarget:self action:@selector(connectTwitter:) forControlEvents:UIControlEventTouchUpInside];
				}
				
				[connectButton sizeToFit];
				cell.accessoryView = connectButton;
			}

			break;
		}
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	return cell;
}

#pragma mark - Helpers

- (void)_signInFlowWithRequest:(NSURLRequest *)request
{
	PLYSocialAuthWebViewController *webVC = [[PLYSocialAuthWebViewController alloc] init];
	//	webVC.authorizationDelegate = self;
	
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVC];
	
	[self presentViewController:nav animated:YES completion:NULL];
	
	[webVC startAuthorizationFlowWithRequest:request completion:^(BOOL isAuthenticated, NSString *token)
	 {
		 [self dismissViewControllerAnimated:YES completion:^{
			 
			 [self.productLayerServer loadDetailsForUser:self.productLayerServer.loggedInUser completion:^(id result, NSError *error) {
				 DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					 
					 _isTwitterBusy = NO;
					 _isFacebookBusy = NO;
					 [self.tableView reloadData];
				 });
			 }];
		 }];
	 }];
}

#pragma mark - Actions

- (void)connectFacebook:(UIButton *)sender
{
	_isFacebookBusy = YES;
	[self.tableView reloadData];
	
	NSURLRequest *request = [self.productLayerServer URLRequestForFacebookConnect];
	[self _signInFlowWithRequest:request];
}

- (void)disconnectFacebook:(UIButton *)sender
{
	_isFacebookBusy = YES;
	[self.tableView reloadData];
	
	[self.productLayerServer disconnectSocialConnectionForFacebook:^(id result, NSError *error) {
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			_isFacebookBusy = NO;
			[self.tableView reloadData];
		});
	}];
}

- (void)connectTwitter:(UIButton *)sender
{
	_isTwitterBusy = YES;
	[self.tableView reloadData];

	NSURLRequest *request = [self.productLayerServer URLRequestForTwitterConnect];
	[self _signInFlowWithRequest:request];
}

- (void)disconnectTwitter:(UIButton *)sender
{
	_isTwitterBusy = YES;
	[self.tableView reloadData];
	
	[self.productLayerServer disconnectSocialConnectionForTwitter:^(id result, NSError *error) {
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			_isTwitterBusy = NO;
			[self.tableView reloadData];
		});
	}];
}

@end
