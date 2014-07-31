//
//  SignUpViewController.m
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "SignUpViewController.h"

#import "DTBlockFunctions.h"
#import "DTProgressHUD.h"

#import "PLYServer.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[self.nicknameTextfield addTarget:self action:@selector(nicknameChanged:) forControlEvents:UIControlEventAllEditingEvents];
	[self.emailTextField addTarget:self action:@selector(emailChanged:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)_updateSaveButtonState
{
	if (self.nicknameTextfield)
	{
		if (![self.nicknameTextfield.text length])
		{
			self.saveButtonItem.enabled = NO;
			return;
		}
	}
	
	if (self.emailTextField)
	{
		if (![self.emailTextField.text length])
		{
			self.saveButtonItem.enabled = NO;
			return;
		}
	}
	
	self.saveButtonItem.enabled = YES;
}

- (IBAction)nicknameChanged:(id)sender
{
	[self _updateSaveButtonState];
}

- (IBAction)emailChanged:(id)sender
{
	[self _updateSaveButtonState];
}

- (IBAction)save:(id)sender
{
    DTProgressHUD *_hud = [[DTProgressHUD alloc] init];
    _hud.showAnimationType = HUDProgressAnimationTypeFade;
    _hud.hideAnimationType = HUDProgressAnimationTypeFade;
    [_hud showWithText:@"signing up" progressType:HUDProgressTypeInfinite];
    
	[[PLYServer sharedServer] createUserWithName:self.nicknameTextfield.text email:self.emailTextField.text completion:^(id result, NSError *error) {
		
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
				
				[self dismissViewControllerAnimated:YES completion:nil];
			});
		}
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            [_hud hide];
        });
	}];
}

- (IBAction) close:(id)sender
{
    DTBlockPerformSyncIfOnMainThreadElseAsync(^{
        
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end