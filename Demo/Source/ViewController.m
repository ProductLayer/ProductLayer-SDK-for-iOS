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
#import "LoginViewController.h"
#import "ProductImageViewController.h"

#import "ProductLayer.h"
#import "ProductLayerConfig.h"
#import "DTScannedCode.h"
#import "DTBlockFunctions.h"
	

@interface ViewController () <DTCodeScannerViewControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController
{
	PLYServer *_server;
	
	NSString *_gtinForEditingProduct;
	
	NSString *_previousScannedGTIN;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_server = [[PLYServer alloc] initWithHostURL:PLY_ENDPOINT_URL];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
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
		vc.gtin = _gtinForEditingProduct;
	}
	else if ([[segue identifier] isEqualToString:@"ProductImages"])
	{
		UINavigationController *navController = segue.destinationViewController;
		ProductImageViewController *vc = (ProductImageViewController *)[navController topViewController];
		vc.navigationItem.title = @"Images";
		vc.gtin = _previousScannedGTIN;
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

- (void)_updateLoginBar
{
	if (_server.loggedInUser)
	{
		[self.loginButton setTitle:@"Log out" forState:UIControlStateNormal];
		self.loginNameLabel.text = _server.loggedInUser;
	}
	else
	{
		self.loginNameLabel.text = @"Not logged in";
		[self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
	}
}

- (void)_updateImagesButtons
{
	BOOL buttonsEnabled = (_previousScannedGTIN!=nil);
	
	self.viewImagesButton.enabled = buttonsEnabled;
	self.addImageButton.enabled = buttonsEnabled;
}

#pragma mark - Actions

- (IBAction)unwindFromScanner:(UIStoryboardSegue *)unwindSegue
{
	
}

- (IBAction)unwindFromSignUp:(UIStoryboardSegue *)unwindSegue
{
	if (![[unwindSegue sourceViewController] isKindOfClass:[LoginViewController class]])
	{
		return;
	}
	
	if (_server.loggedInUser)
	{
		[self.loginButton setTitle:@"Log out" forState:UIControlStateNormal];
	}
	else
	{
		self.loginNameLabel.text = @"Not logged in";
		[self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
	}
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
	if (_server.loggedInUser)
	{
		[_server logoutUserWithCompletion:^(id result, NSError *error) {
			
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

- (IBAction)addImageToProduct:(id)sender
{
	if (![_previousScannedGTIN length])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot add Image" message:@"Please scan something first, we need a GTIN to add an image to" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		
		return;
	}
	
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.delegate = (id)self;
	
	[self presentViewController:imagePickerController animated:YES completion:nil];
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
					
					_previousScannedGTIN = nil;
					_lastScannedCodeLabel.text = @"Not Found";
					
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
					
					_previousScannedGTIN = code.content;
					_lastScannedCodeLabel.text = code.content;
					
					[self _updateImagesButtons];

					[codeScanner performSegueWithIdentifier:@"UnwindFromScanner" sender:self];
				});
			}
		}];
	}
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissViewControllerAnimated:YES completion:NULL];

	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	NSData *data = UIImageJPEGRepresentation(image, 0.5);
	
	[_server uploadFileData:data forGTIN:_previousScannedGTIN completion:^(id result, NSError *error) {
		
		NSLog(@"%@ %@", result, error);
	}];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
