//
//  ViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ViewController.h"
#import "SignUpViewController.h"

#import "ProductLayer.h"
#import "ProductLayerConfig.h"
#import "DTScannedCode.h"
#import "DTBlockFunctions.h"
	

@interface ViewController () <DTCodeScannerViewControllerDelegate>

@end

@implementation ViewController
{
	PLYServer *_server;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_server = [[PLYServer alloc] initWithHostURL:PLY_ENDPOINT_URL];
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
	if ([code.type isEqualToString:PLYCodeTypeEAN13])
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
				DTBlockPerformSyncIfOnMainThreadElseAsync(^{
					
					[codeScanner performSegueWithIdentifier:@"UnwindFromScanner" sender:self];
				});
			}
		}];
		
		
	}
}



@end
