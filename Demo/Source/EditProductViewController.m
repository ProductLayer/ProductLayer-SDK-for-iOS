//
//  EditProductViewController.m
//  PL
//
//  Created by Oliver Drobnik on 23/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "EditProductViewController.h"
#import "DTBlockFunctions.h"

@implementation EditProductViewController

- (void)viewDidLoad
{
	[self.gtinTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.productNameTextfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.vendorTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.categoryTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
	
	self.gtinTextField.text = _gtin;
	
	[self _updateSaveButtonStatus];
}

- (void)_updateSaveButtonStatus
{
	if (![self.gtinTextField.text length])
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		return;
	}
	
	if (![self.productNameTextfield.text length])
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		return;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = YES;
}


#pragma mark - Actions


- (void)textFieldChanged:(id)sender
{
	[self _updateSaveButtonStatus];
}

- (IBAction)save:(id)sender
{
	NSAssert(_server, @"Server needs to be set");
	
	_gtin = self.gtinTextField.text;
	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:_gtin forKey:@"pl-prod-gtin"];

	NSString *name = self.productNameTextfield.text;
	if ([name length])
	{
		dictionary[@"pl-prod-name"] = name;
	}
	
	NSString *vendor = self.vendorTextField.text;
	if ([vendor length])
	{
		dictionary[@"pl-brand-name"] = vendor;
	}

	NSString *category = self.categoryTextField.text;
	if ([category length])
	{
		dictionary[@"pl-prod-cat"] = category;
	}
	
	NSLocale *locale = [NSLocale currentLocale];
	dictionary[@"pl-lng"] = locale.localeIdentifier;

	[self.server createProductWithGTIN:_gtin dictionary:dictionary completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Product Creation Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				
				[self performSegueWithIdentifier:@"UnwindFromEditProduct" sender:self];
			});
		}
	}];
	
}
@end
