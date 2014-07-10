//
//  ViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "HomeViewController.h"
#import "SignUpViewController.h"
#import "EditProductViewController.h"
#import "LoginViewController.h"
#import "ProductImageViewController.h"

#import "ProductLayer.h"
#import "DTScannedCode.h"
#import "DTBlockFunctions.h"
#import "UIViewController+DTSidePanelController.h"
#import "DTSidePanelController.h"
#import "SearchProductViewController.h"
#import "WriteReviewViewController.h"
#import "ProductViewController.h"

#import "UIViewTags.h"
#import "DTAlertView.h"
#import "AppSettings.h"

#import "PLYProduct.h"
#import "PLYUser.h"


@interface HomeViewController () <DTCodeScannerViewControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation HomeViewController
{
	NSString *_gtinForEditingProduct;
	
	NSString *_previousScannedGTIN;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Set the side bar button action. When it's tapped, it'll show up the sidebar.
	_sidebarButton.target = self.getSidePanelController;
	_sidebarButton.action = @selector(showLeftPanel:);
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateLoginBar) name:PLYNotifyUserStatusChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(![self.navigationController.navigationBar viewWithTag:ProductLayerTitleImage]) {
		UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"productlayer_title.png"]];
		[titleImageView setTag:ProductLayerTitleImage];
		[self.navigationController.navigationBar addSubview:titleImageView];
	}
	
	//Changing Tint Color!
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:110.0/255.0
																							  green:190.0/255.0
																								blue:68.0/255.0
																							  alpha:1.0];
	
	[self _updateLoginBar];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (animated && _gtinForEditingProduct)
	{
		[self performSegueWithIdentifier:@"EditProduct" sender:self];
		_gtinForEditingProduct = nil;
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"ScanBarcode"])
	{
		UINavigationController *navController = segue.destinationViewController;
		DTCodeScannerViewController *scannerVC = (DTCodeScannerViewController *)[navController topViewController];
		scannerVC.scanDelegate = self;
	}
	else if ([[segue identifier] isEqualToString:@"EditProduct"])
	{
		UINavigationController *navController = segue.destinationViewController;
		EditProductViewController *vc = (EditProductViewController *)[navController topViewController];
		vc.navigationItem.title = @"Add New Product";
		
		PLYProduct *newProduct = [[PLYProduct alloc] init];
		[newProduct setGtin:_gtinForEditingProduct];
		[vc setProduct:newProduct];
	}
	else if ([[segue identifier] isEqualToString:@"ProductImages"])
	{
		UINavigationController *navController = segue.destinationViewController;
		ProductImageViewController *vc = (ProductImageViewController *)[navController topViewController];
		vc.navigationItem.title = @"Images";
		vc.gtin = _previousScannedGTIN;
	}
	else if ([[segue identifier] isEqualToString:@"WriteReview"])
	{
		UINavigationController *navController = segue.destinationViewController;
		WriteReviewViewController *vc = (WriteReviewViewController *)[navController topViewController];
		vc.navigationItem.title = @"Write Review";
		vc.gtin = _previousScannedGTIN;
	}
}

- (void)_updateLoginBar
{
	
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		if ([[PLYServer sharedServer] loggedInUser])
		{
			[self.loginButton setTitle:[[[PLYServer sharedServer] loggedInUser] nickname] forState:UIControlStateNormal];
		}
		else
		{
			[self.loginButton setTitle:@"Sign in" forState:UIControlStateNormal];
		}
	});
}

#pragma mark - Actions

- (IBAction)unwindFromScanner:(UIStoryboardSegue *)unwindSegue
{
	
}

- (IBAction)unwindFromLogin:(UIStoryboardSegue *)unwindSegue
{
	[self _updateLoginBar];
}

- (IBAction)unwindToRoot:(UIStoryboardSegue *)unwindSegue
{
	
}


- (IBAction)login:(id)sender
{
	if ([[PLYServer sharedServer] loggedInUser])
	{
		DTAlertView *alertView = [[DTAlertView alloc] initWithTitle:@"Logout?" message:@"Do you realy want to logout?"];
		
		[alertView addButtonWithTitle:@"yes" block:^() {
			[[PLYServer sharedServer] logoutUserWithCompletion:^(id result, NSError *error) {
				
				DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					
					[self _updateLoginBar];
					
					if (error)
					{
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
						[alert show];
						
					}
				});
			}];
		}];
		
		[alertView addCancelButtonWithTitle:@"No" block:^() {
			// Don't log out.
		}];
		
		[alertView show];
	}
	else
	{
		[self performSegueWithIdentifier:@"LogIn" sender:self];
	}
}

#pragma mark - DTCodeScannerViewControllerDelegate


- (void)codeScanner:(DTCodeScannerViewController *)codeScanner didScanCode:(DTScannedCode *)code
{
	if ([code.type isEqualToString:PLYCodeTypeEAN13] || [code.type isEqualToString:PLYCodeTypeEAN8])
	{
		DTBlockPerformSyncIfOnMainThreadElseAsync(^{
			[codeScanner performSegueWithIdentifier:@"UnwindFromScanner" sender:self];
			
			UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
			ProductViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
			[viewController loadProductWithGTIN:code.content];
			[self.navigationController pushViewController:viewController animated:YES];
		});
	}
}

#pragma mark - UISearchBarDelegate

- (void) searchBarTextDidBeginEditing: (UISearchBar*) searchBar {
	[_productSearchBar setShowsCancelButton: YES animated: YES];
	[self activateSearchMode];
	
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
	[_productSearchBar setText:@""];
	[self deactivateSearchMode];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[self deactivateSearchMode];
	
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	
	SearchProductViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchProductViewController"];
	[self.navigationController pushViewController:viewController animated:YES];
	
	[viewController searchBarSearchButtonClicked:searchBar];
}

- (void) activateSearchMode{
	[_productSearchBar setShowsCancelButton: YES animated: YES];
	
	[UIView animateWithDuration:0.2 animations:^{
		double yDiff = - self.navigationController.navigationBar.frame.size.height;
		self.navigationController.navigationBar.alpha = 0.0f;
		self.scanBarcodeButton.alpha = 0.0f;
		self.productSearchBar.frame = CGRectMake(self.productSearchBar.frame.origin.x,
															  self.productSearchBar.frame.origin.y,
															  320,
															  self.productSearchBar.frame.size.height);
		self.navigationController.view.frame = CGRectMake(0, yDiff, 320, self.navigationController.view.frame.size.height);
	}];
}

- (void) deactivateSearchMode{
	[_productSearchBar resignFirstResponder];
	[_productSearchBar setShowsCancelButton: NO animated: YES];
	
	[UIView animateWithDuration:0.2 animations:^{
		double yDiff = 0;
		self.navigationController.navigationBar.alpha = 1.0f;
		self.scanBarcodeButton.alpha = 1.0f;
		self.productSearchBar.frame = CGRectMake(self.productSearchBar.frame.origin.x,
															  self.productSearchBar.frame.origin.y,
															  320 - self.scanBarcodeButton.frame.size.width,
															  self.productSearchBar.frame.size.height);
		self.navigationController.view.frame = CGRectMake(0, yDiff, 320, self.navigationController.view.frame.size.height);
	}];
}

@end
