//
//  MenuViewController.m
//  PL
//
//  Created by René Swoboda on 23/04/14.
//  Copyright (c) 2014 productlayer. All rights reserved.
//

#import "MenuViewController.h"
#import "HomeViewController.h"
#import "ProductLayerConfig.h"

#import "PLYServer.h"

#import "DTAlertView.h"
#import "DTBlockFunctions.h"
#import "DTSidePanelController.h"
#import "DTSidePanelControllerSegue.h"

#import "HomeViewController.h"
#import "ProductListsViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController{
}

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
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if (( [identifier isEqualToString:@"showMyProductLists"] || [identifier isEqualToString:@"createProduct"]) && ![self checkIfLoggedInAndShowLoginView:YES])
	{
        return false;
    }
    
    return YES;
    
}

-(void) prepareForSegue:(UIStoryboardSegue *) segue sender: (id) sender
{
    if ( [segue isKindOfClass: [DTSidePanelControllerSegue class]] ) {
        DTSidePanelControllerSegue *_segue = (DTSidePanelControllerSegue*) segue;
        
        _segue.performBlock = ^(DTSidePanelControllerSegue* _segue, UIViewController* source, id destination) {
            UINavigationController* navController = (UINavigationController*)self.getSidePanelController.centerPanelController;
            [navController setViewControllers: @[destination] animated: NO ];
            
            if ([[segue identifier] isEqualToString:@"showMyProductLists"])
            {
                ProductListsViewController *productLists = destination;
                productLists.addProductView = false;
                [productLists loadProductListsForUser:[[PLYServer sharedServer] loggedInUser] andType:nil];
            }
            
            [self.getSidePanelController presentPanel:DTSidePanelControllerPanelCenter animated:YES];
        };
    }
}

- (IBAction)unwindToMenu:(UIStoryboardSegue *)unwindSegue
{
	
}

- (IBAction)unwindFromSignUp:(UIStoryboardSegue *)unwindSegue
{
    
}

@end
