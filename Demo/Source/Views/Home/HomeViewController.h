//
//  ViewController.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTCodeScannerViewController.h"
#import "SocialFeedViewController.h"

@interface HomeViewController : UIViewController <UISearchBarDelegate, UIAlertViewDelegate>

- (IBAction)unwindFromScanner:(UIStoryboardSegue *)unwindSegue;

- (IBAction)unwindFromLogin:(UIStoryboardSegue *)unwindSegue;

- (IBAction)unwindToRoot:(UIStoryboardSegue *)unwindSegue;

- (IBAction)login:(id)sender;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UISearchBar *productSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *scanBarcodeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
