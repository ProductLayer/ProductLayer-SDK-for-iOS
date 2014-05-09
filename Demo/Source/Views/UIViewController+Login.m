//
//  UIViewController+Login.m
//  PL
//
//  Created by René Swoboda on 09/05/14.
//  Copyright (c) 2014 Cocoanetics. All rights reserved.
//

#import "UIViewController+Login.h"
#import "ProductLayer.h"
#import "DTBlockFunctions.h"
#import "DTAlertView.h"
#import "LoginViewController.h"

@implementation UIViewController (UIViewControllerLogin)

- (BOOL) checkIfLoggedInAndShowLoginView:(BOOL) showLogin{
    if (![[PLYServer sharedPLYServer] loggedInUser])
    {
        if(showLogin){
            DTAlertView *alertView = [[DTAlertView alloc] initWithTitle:@"Login required" message:@"Do you want to login?"];
            
            [alertView addButtonWithTitle:@"Login" block:^() {
                DTBlockPerformSyncIfOnMainThreadElseAsync(^{
                    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
                                                                  bundle:nil];
                    LoginViewController* loginVC = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginVC];
                    [self presentViewController:navController animated:YES completion:nil];
                });
            }];
            
            [alertView addCancelButtonWithTitle:@"Cancel" block:^() {
                // Don't log out.
            }];
            
            
            [alertView show];
        }
        return false;
    }
    return true;
}

@end
