//
//  LoginViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "LoginViewController.h"
#import "DTBlockFunctions.h"

#import "ProductLayer.h"

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.passwordTextfield addTarget:self action:@selector(passwordChanged:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
	[self.nicknameTextfield becomeFirstResponder];
}

- (void)_updateSaveButtonState
{
	if (self.passwordTextfield)
	{
		if (![self.passwordTextfield.text length])
		{
			self.saveButtonItem.enabled = NO;
			return;
		}
	}
	
	[super _updateSaveButtonState];
}

- (IBAction)save:(id)sender
{
	[[PLYServer sharedPLYServer] loginWithUser:self.nicknameTextfield.text password:self.passwordTextfield.text completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                if(error.code == 401){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Nickname and password are not matching!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				[self dismissViewControllerAnimated:YES completion:nil];
			});
		}
		
	}];
}

- (IBAction) cancel:(id)sender{
    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)passwordChanged:(id)sender
{
	[self _updateSaveButtonState];
}



@end
