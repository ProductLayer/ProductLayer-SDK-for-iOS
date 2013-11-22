//
//  SignUpViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "SignUpViewController.h"
#import "PLYServer.h"
#import "DTBlockFunctions.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
	[self.nicknameTextfield addTarget:self action:@selector(nicknameChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.emailTextField addTarget:self action:@selector(emailChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.passwordTextfield addTarget:self action:@selector(passwordChanged:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)_updateSaveButtonState
{
	if ([self.nicknameTextfield.text length] && [self.passwordTextfield.text length] && [self.emailTextField.text length])
	{
		self.saveButtonItem.enabled = YES;
	}
	else
	{
		self.saveButtonItem.enabled = NO;
	}
}

- (IBAction)nicknameChanged:(id)sender
{
	[self _updateSaveButtonState];
}

- (IBAction)emailChanged:(id)sender
{
	[self _updateSaveButtonState];
}

- (IBAction)passwordChanged:(id)sender
{
	[self _updateSaveButtonState];
}

- (IBAction)save:(id)sender
{
	NSAssert(_server, @"Server needs to be set");
	
	[self.server createUserWithNickname:self.nicknameTextfield.text email:self.emailTextField.text password:self.passwordTextfield.text completion:^(id result, NSError *error) {
		
		if (error)
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign Up Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
				[alert show];
			});
		}
		else
		{
			DTBlockPerformSyncIfOnMainThreadElseAsync(^{
				
				[self performSegueWithIdentifier:@"UnwindFromSignUp" sender:self];
			});
		}
	}];
}

@end
