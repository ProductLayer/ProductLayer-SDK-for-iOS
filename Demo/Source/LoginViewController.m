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

- (IBAction)save:(id)sender
{
	NSAssert(self.server, @"Server needs to be set");
	
	[self.server loginWithNickname:@"drops" password:@"magic" completion:^(id result, NSError *error) {
		
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
				[self performSegueWithIdentifier:@"UnwindFromSignUp" sender:self];
			});
		}
		
	}];
}
@end
