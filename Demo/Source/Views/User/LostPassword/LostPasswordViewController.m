//
//  LostPasswordViewController.m
//  PL
//
//  Created by René Swoboda on 07/05/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "LostPasswordViewController.h"

#import "ProductLayer.h"

#import "DTBlockFunctions.h"

@interface LostPasswordViewController ()

@end

@implementation LostPasswordViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.emailTextfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldChanged:(id)sender
{
	[self _updateSaveButtonStatus];
}

- (void)_updateSaveButtonStatus
{
	if (![self.emailTextfield.text length] || ![self NSStringIsValidEmail:self.emailTextfield.text])
	{
		self.navigationItem.rightBarButtonItem.enabled = NO;
		return;
	}
	
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (IBAction) requestNewPassword:(id)sender{
    [[PLYServer sharedPLYServer] requestNewPasswordForUserWithEmail:_emailTextfield.text completion:^(id result, NSError *error) {
        
        DTBlockPerformSyncIfOnMainThreadElseAsync(^{
            if (error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Password Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
    }];
}

@end
