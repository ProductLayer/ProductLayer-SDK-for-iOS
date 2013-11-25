//
//  ViewController.h
//  PL
//
//  Created by Oliver Drobnik on 22.11.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DTCodeScannerViewController.h"

@interface ViewController : UIViewController

- (IBAction)unwindFromScanner:(UIStoryboardSegue *)unwindSegue;

- (IBAction)unwindFromSignUp:(UIStoryboardSegue *)unwindSegue;

- (IBAction)unwindFromLogin:(UIStoryboardSegue *)unwindSegue;

- (IBAction)unwindToRoot:(UIStoryboardSegue *)unwindSegue;

- (IBAction)addImageToProduct:(id)sender;

- (IBAction)login:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addImageButton;
@property (weak, nonatomic) IBOutlet UIButton *viewImagesButton;

@property (weak, nonatomic) IBOutlet UILabel *lastScannedCodeLabel;
@end
