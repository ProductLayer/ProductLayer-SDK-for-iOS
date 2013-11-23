//
//  ViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ViewController.h"
#import "SignUpViewController.h"
#import "EditProductViewController.h"

#import "ProductLayer.h"
#import "ProductLayerConfig.h"
#import "DTScannedCode.h"
#import "DTBlockFunctions.h"
	

@interface ViewController () <DTCodeScannerViewControllerDelegate>

@end

@implementation ViewController
{
	PLYServer *_server;
	
	NSString *_gtinForEditingProduct;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_server = [[PLYServer alloc] initWithHostURL:PLY_ENDPOINT_URL];
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
		vc.gtin = _gtinForEditingProduct;
	}
	
	// inject server
	if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
	{
		UINavigationController *navController = segue.destinationViewController;
		id topVC = navController.topViewController;
		
		if ([topVC respondsToSelector:@selector(setServer:)])
		{
			[topVC setServer:_server];
		}
	}
}

- (IBAction)unwindFromScanner:(UIStoryboardSegue *)unwindSegue
{
	
}

- (IBAction)unwindFromSignUp:(UIStoryboardSegue *)unwindSegue
{
	
}

- (IBAction)unwindFromLogin:(UIStoryboardSegue *)unwindSegue
{
	
}

- (IBAction)unwindToRoot:(UIStoryboardSegue *)unwindSegue
{
	
}

- (IBAction)logout:(id)sender
{
	[_server logoutUserWithCompletion:^(id result, NSError *error) {
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				
			});
		}
	}];
}

#pragma mark - DTCodeScannerViewControllerDelegate


- (void)codeScanner:(DTCodeScannerViewController *)codeScanner didScanCode:(DTScannedCode *)code
{
	if ([code.type isEqualToString:PLYCodeTypeEAN13] || [code.type isEqualToString:PLYCodeTypeEAN8])
	{
		NSLocale *locale = [NSLocale currentLocale];
		
		[_server performSearchForGTIN:code.content language:locale.localeIdentifier completion:^(id result, NSError *error) {
			
			if (error)
			{
				DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alert show];
				});
			}
			else
			{
				if (![result count])
				{
					_gtinForEditingProduct = code.content;
				}
				else
				{
					NSDictionary *firstItem = result[0];
					NSString *name = firstItem[@"name"];
					NSString *gtin = firstItem[@"gtin"];
					
					DTBlockPerformSyncIfOnMainThreadElseAsync(^{
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:gtin message:name delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
						[alert show];
					});
				}
				
				DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					[codeScanner performSegueWithIdentifier:@"UnwindFromScanner" sender:self];
				});
			}
		}];
	}
}



@end
