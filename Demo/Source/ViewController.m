//
//  ViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "ViewController.h"
#import "ProductLayer.h"
#import "ProductLayerConfig.h"
#import "DTScannedCode.h"
	

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
	if ([[segue identifier] isEqualToString:@"ScanBarCode"])
	{
		DTCodeScannerViewController *scannerVC = segue.destinationViewController;
		scannerVC.scanDelegate = self;
	}
}

- (IBAction)unwindFromScanner:(UIStoryboardSegue *)unwindSegue
{
	
}

#pragma mark - DTCodeScannerViewControllerDelegate


- (void)codeScanner:(DTCodeScannerViewController *)codeScanner didScanCode:(DTScannedCode *)code
{
	if ([code.type isEqualToString:PLYCodeTypeEAN13])
	{
		NSLocale *locale = [NSLocale currentLocale];
		
		[_server performSearchForGTIN:code.content language:locale.localeIdentifier completion:^(id result, NSError *error) {
			
			if (result)
			{
				NSLog(@"%@", result);
			}
			else
			{
				NSLog(@"%@", error);
			}
		}];
	}
	
	[codeScanner performSegueWithIdentifier:@"UnwindFromScanner" sender:self];
}

@end
