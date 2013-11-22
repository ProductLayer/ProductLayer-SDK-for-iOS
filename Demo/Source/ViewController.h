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

@end
