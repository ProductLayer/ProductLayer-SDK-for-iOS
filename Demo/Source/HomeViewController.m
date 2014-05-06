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
#import "ProductLayerConfig.h"
#import "DTScannedCode.h"
#import "DTBlockFunctions.h"
#import "SearchProductViewController.h"
#import "WriteReviewViewController.h"
#import "ProductViewController.h"
#import "SWRevealViewController.h"

#import "UIViewTags.h"
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
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

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
    
    self.productImagesVC.collectionView = self.collectionView;
    [self.productImagesVC loadLastImages];
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
        if ([[PLYServer sharedPLYServer] loggedInUser])
        {
            [self.loginButton setTitle:[[[PLYServer sharedPLYServer] loggedInUser] nickname] forState:UIControlStateNormal];
        }
        else
        {
            [self.loginButton setTitle:@"Sign in" forState:UIControlStateNormal];
        }
    });
}

- (void)_updateImagesButtons
{
	BOOL buttonsEnabled = (_previousScannedGTIN!=nil);
	
    self.writeReviewButton.enabled = buttonsEnabled;
	self.viewImagesButton.enabled = buttonsEnabled;
	self.addImageButton.enabled = buttonsEnabled;
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
	if ([[PLYServer sharedPLYServer] loggedInUser])
	{
		[[PLYServer sharedPLYServer] logoutUserWithCompletion:^(id result, NSError *error) {
			
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				
				[self _updateLoginBar];
				
				if (error)
				{
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alert show];
					
				}
			});
		}];
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
		[[PLYServer sharedPLYServer] performSearchForGTIN:code.content language:[AppSettings currentAppLocale].localeIdentifier completion:^(id result, NSError *error) {

			if (error)
			{
				DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					
					_previousScannedGTIN = nil;
					_lastScannedCodeLabel.text = @"Not Found";
					
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alert show];
				});
			}
			else
			{
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					
					_previousScannedGTIN = code.content;
					_lastScannedCodeLabel.text = code.content;
					
					[self _updateImagesButtons];
                    
					[codeScanner performSegueWithIdentifier:@"UnwindFromScanner" sender:self];
				});
                
				if (![result count])
				{
					_gtinForEditingProduct = code.content;
				}
				else
				{
					PLYProduct *firstItem = result[0];
                    
                    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        ProductViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ProductViewController"];
                        [viewController setProduct:firstItem];
                        [self.navigationController pushViewController:viewController animated:YES];
                    });
				}
			}
		}];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SearchProductViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchProductViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
    
    [viewController searchBarSearchButtonClicked:searchBar];
}

@end
