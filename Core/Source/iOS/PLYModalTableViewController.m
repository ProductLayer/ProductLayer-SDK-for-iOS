//
//  PLYModalTableViewController.m
//  ProdlyApp
//
//  Created by Oliver Drobnik on 25/01/15.
//  Copyright (c) 2015 ProductLayer. All rights reserved.
//

#import "PLYModalTableViewController.h"
#import "DTBlockFunctions.h"
#import "ProductLayerSDK.h"

@interface PLYModalTableViewController ()

@end

@implementation PLYModalTableViewController
{
	UIBarButtonItem *_cancelButtonItem;
	UIBarButtonItem *_saveButtonItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = _cancelButtonItem;

	_saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = _saveButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	// dismiss keyboard
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)_saveDidFinish
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)_saveDidFail
{
	self.navigationItem.rightBarButtonItem = _saveButtonItem;
}

- (void)performAsyncSaveOperationWithCompletion:(void(^)(NSError *))completion
{
	// default is always success
	completion(nil);
}

- (NSString *)titleForErrorDialog
{
	return @"Error Saving";
}

#pragma mark - Helpers

- (void)_beginSaving
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		self.navigationItem.leftBarButtonItem = nil;
		
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activity];
		
		[activity startAnimating];
	});
}

- (void)_endSaving
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		self.navigationItem.leftBarButtonItem = _cancelButtonItem;
		self.navigationItem.rightBarButtonItem = _saveButtonItem;
	});
}

- (void)_savingComplete
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		UIBarButtonItem *check = [[UIBarButtonItem alloc] initWithTitle:@"👍" style:UIBarButtonItemStylePlain target:nil action:NULL];
		check.tintColor = self.navigationController.view.tintColor;
		self.navigationItem.rightBarButtonItem = check;
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self dismissViewControllerAnimated:YES completion:NULL];
		});
	});
}

- (void)_showError:(NSError *)error
{
	DTBlockPerformSyncIfOnMainThreadElseAsync(^{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[self titleForErrorDialog]
																		message:[error localizedDescription]
																	  delegate:nil
														  cancelButtonTitle:PLYLocalizedStringFromTable(@"PLY_ALERT_OK", @"UI", @"Alert acknowledgement button title")
														  otherButtonTitles:nil];
		alert.tintColor = [UIColor redColor];
		[alert show];
	});
}


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)save:(id)sender
{
	void (^completion)(NSError *) = ^(NSError *error) {
		if (error)
		{
			[self _showError:error];
			[self _endSaving];
		}
		else
		{
			[self _savingComplete];
		}
	};
	
	[self _beginSaving];
	[self performAsyncSaveOperationWithCompletion:completion];
}


@end
