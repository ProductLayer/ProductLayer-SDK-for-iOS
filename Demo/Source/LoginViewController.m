//
//  LoginViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22/11/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "LoginViewController.h"
#import "DTBlockFunctions.h"

#import "PLYServer.h"

@implementation LoginViewController

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self.nicknameTextfield becomeFirstResponder];
}

- (IBAction)save:(id)sender
{
	
	[[PLYServer sharedPLYServer] loginWithUser:self.nicknameTextfield.text password:self.passwordTextfield.text completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				[self performSegueWithIdentifier:@"UnwindFromLogin" sender:self];
			});
		}
		
	}];
}

@end
