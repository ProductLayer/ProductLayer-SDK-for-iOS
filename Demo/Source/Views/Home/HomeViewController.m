//
//  ViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "HomeViewController.h"
#import "EditProductViewController.h"
#import "ProductImageViewController.h"

#import "ProductLayer.h"
#import "DTFoundation.h"

#import "SearchProductViewController.h"
#import "WriteReviewViewController.h"
#import "ProductViewController.h"

#import "UIViewTags.h"
#import "DTAlertView.h"
#import "AppSettings.h"

#import "DTProgressHUD.h"


@interface HomeViewController () <PLYScannerViewControllerDelegate, UIImagePickerControllerDelegate>

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
	_sidebarButton.target = self.sidePanelController;
	_sidebarButton.action = @selector(toggleLeftPanel:);
	
	// observe logged in user so that we can update login button
	[[PLYServer sharedServer] addObserver:self forKeyPath:@"loggedInUser" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"loggedInUser"])
	{
		[self _updateLoginBar];
	}
}

- (void)dealloc
{
    // UISearchBarDelegate is not weak so we need to set it nil via code.
    self.productSearchBar.delegate = nil;
	
	// clean up observings
	[[PLYServer sharedServer] removeObserver:self forKeyPath:@"loggedInUser"];
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
		PLYScannerViewController *scannerVC = (PLYScannerViewController *)[navController topViewController];
		scannerVC.delegate = self;
	}
	else if ([[segue identifier] isEqualToString:@"EditProduct"])
	{
		UINavigationController *navController = segue.destinationViewController;
		EditProductViewController *vc = (EditProductViewController *)[navController topViewController];
		vc.navigationItem.title = @"Add New Product";
		
		PLYProduct *newProduct = [[PLYProduct alloc] init];
		newProduct.GTIN = _gtinForEditingProduct;
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
            [self.loginButton setTitle:[[[PLYServer sharedServer] loggedInUser] nickname]];
            [self.loginButton setEnabled:true];
		}
		else
		{
            if([[PLYServer sharedServer] performingLogin])
            {
                [self.loginButton setTitle:@"loading ..."];
                [self.loginButton setEnabled:false];
            } else {
                [self.loginButton setTitle:@"Sign in"];
                [self.loginButton setEnabled:true];
            }
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
        __weak HomeViewController *weakSelf = self;
        
		DTAlertView *alertView = [[DTAlertView alloc] initWithTitle:@"Logout?" message:@"Do you realy want to logout?"];
		
		[alertView addButtonWithTitle:@"yes" block:^() {
			[[PLYServer sharedServer] logoutUserWithCompletion:^(id result, NSError *error) {
				
				DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					
					[weakSelf _updateLoginBar];
					
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

#pragma mark - PLYScannerViewControllerDelegate

- (void)scanner:(PLYScannerViewController *)scanner didScanGTIN:(NSString *)GTIN
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		[scanner performSegueWithIdentifier:@"UnwindFromScanner" sender:self];
		
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
		ProductViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController loadProductWithGTIN:GTIN];
	});
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
