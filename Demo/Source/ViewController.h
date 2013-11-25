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

- (IBAction)logout:(id)sender;

- (IBAction)addImageToProduct:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lastScannedCodeLabel;
@end
