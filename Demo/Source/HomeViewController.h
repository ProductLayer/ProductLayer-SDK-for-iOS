//
//  ViewController.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTCodeScannerViewController.h"
#import "ProductImageViewController.h"

@interface HomeViewController : UIViewController

- (IBAction)unwindFromScanner:(UIStoryboardSegue *)unwindSegue;

- (IBAction)unwindFromLogin:(UIStoryboardSegue *)unwindSegue;

- (IBAction)unwindToRoot:(UIStoryboardSegue *)unwindSegue;

- (IBAction)login:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIButton *viewImagesButton;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;
@property (weak, nonatomic) IBOutlet UISearchBar *productSearchBar;
@property (weak, nonatomic) IBOutlet ProductImageViewController *productImagesVC;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (weak, nonatomic) IBOutlet UILabel *lastScannedCodeLabel;
@end
